import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/emergency_mode/presentation/screens/emergency_mode_screen.dart';
import 'package:fiuuassistant/screen/navigation_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fiuuassistant/features/admin/presentation/widgets/web_auth_gate.dart';
import 'package:fiuuassistant/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiuuassistant/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_alert_service.dart';
import 'package:fiuuassistant/features/emergency_mode/services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forzar inicialización temprana de SharedPreferences
  // Esto es crítico para evitar errores "No instance with no name has been registered"
  try {
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences inicializado con éxito');
    // Forzar que se mantenga la instancia
    // Esto previene problemas de inicialización tardía
  } catch (e) {
    debugPrint('⚠️ Error inicializando SharedPreferences: $e');
    // Reintentar una vez más
    try {
      await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences reinicializado');
    } catch (secondError) {
      debugPrint('❌ Error crítico al inicializar SharedPreferences: $secondError');
    }
  }
  
  FlutterForegroundTask.initCommunicationPort();
  await dotenv.load(fileName: ".env");
  
  // Inicializar AudioService
  await AudioService.initialize();
  
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'emergency_service_channel',
      channelName: 'Fiuu Assistant Emergency',
      channelDescription: 'Background service for emergency shake detection',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.nothing(),
      allowWakeLock: true,
      allowWifiLock: true,
      allowAutoRestart: true,
      stopWithTask: false,
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // User is signed in, synchronize data
    await SyncService().syncAllUserData();
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _waitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeEmergencySystem());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      unawaited(_initializeEmergencySystem());
    }
  }

  Future<void> _initializeEmergencySystem() async {
    try {
      await _checkPendingEmergency();
      if (kIsWeb) return;
      await EmergencyService.requestEmergencyPermissions();
      final locationReady =
          await EmergencyAlertService.requestBackgroundLocationPermission();
      if (!locationReady) {
        if (!mounted) return;
        final context = _navigatorKey.currentContext;
        if (context == null) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Permiso de ubicación necesario'),
            content: const Text(
              'Para enviar tu ubicación al contacto de emergencia cuando la '
              'app esté en segundo plano, permite el acceso a la ubicación '
              'en los ajustes de la aplicación.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cerrar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  _waitingForSettings = true;
                  final opened = await openAppSettings();
                  if (!opened) _waitingForSettings = false;
                },
                child: const Text('Abrir ajustes'),
              ),
            ],
          ),
        );
        return;
      }
      await EmergencyService.startIfEnabled(_navigatorKey);
    } catch (error, stackTrace) {
      debugPrint('Error inicializando emergencias: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _checkPendingEmergency() async {
    try {
      // Esperar a que SharedPreferences esté listo
      // Usar un timeout para evitar bloqueo infinito
      final prefs = await SharedPreferences.getInstance();
      final bool isEmergency = prefs.getBool(EmergencyService.pendingEmergencyKey) ?? false;

      if (!isEmergency) {
        debugPrint('✅ No existen emergencias pendientes');
        return;
      }
      final timestamp = prefs.getInt(
        EmergencyService.pendingEmergencyTimestampKey,
      );
      final bool isRecent =
          timestamp != null &&
          DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(timestamp),
              ) <=
              const Duration(minutes: 2);

      // Limpiar siempre el estado para evitar ciclos.
      await prefs.setBool(EmergencyService.pendingEmergencyKey, false);
      await prefs.remove(EmergencyService.pendingEmergencyTimestampKey);

      if (!isRecent) {
        debugPrint('⚠️ Emergencia antigua descartada');
        return;
      }

      debugPrint('🚨 Recuperando emergencia pendiente');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      _navigatorKey.currentState?.pushNamed('/emergency');
    } catch (e) {
      debugPrint('⚠️ Error al verificar emergencia pendiente: $e');
      return;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    EmergencyService.stop();
    AudioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Fiuu Assistant',
        initialRoute: '/',
        routes: {
          '/': (context) => MainWrapper(),
          '/emergency': (context) => EmergencyModeScreen(),
        },
      ),
    );
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebAuthGate(child: AdminDashboard());
    } else {
      return const NavigationShellScreen();
    }
  }
}
