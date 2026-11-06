import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'
    hide NotificationPriority, NotificationVisibility;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emergency_alert_service.dart';

class EmergencyService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isEmergencyActive = false;
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  // Instancia singleton de SharedPreferences para evitar múltiples inicializaciones
  static SharedPreferences? _prefs;
  
  static Future<SharedPreferences> get _getPrefs async {
    // Usar lock para asegurar acceso thread-safe
    // En Android, SharedPreferences NO es thread-safe
    
    if (_prefs == null) {
      // Intentar obtener prefs con manejo de errores
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('⚠️ Error al obtener SharedPreferences: $e');
        // Reintentar una vez
        try {
          _prefs = await SharedPreferences.getInstance();
        } catch (secondError) {
          debugPrint('❌ Error crítico al obtener SharedPreferences: $secondError');
          rethrow;
        }
      }
    }
    return _prefs!;
  }
  
  /// Bandera para sincronizar acceso a SharedPreferences
  /// En Android, SharedPreferences NO es thread-safe
  static bool _prefsOperationInProgress = false;
  
  /// Ejecuta una operación con SharedPreferences de manera thread-safe
  /// Esto es crítico en Android donde SharedPreferences no es thread-safe
  static Future<T> _runWithPrefsLock<T>(Future<T> Function(SharedPreferences) action) async {
    // Implementación de sincronización simple usando una bandera
    // Esto asegura que solo una operación acceda a prefs a la vez
    
    // Esperar si hay una operación en progreso
    while (_prefsOperationInProgress) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    _prefsOperationInProgress = true;
    try {
      final prefs = await _getPrefs;
      final result = await action(prefs);
      return result;
    } catch (e) {
      debugPrint('⚠️ Error en operación thread-safe: $e');
      rethrow;
    } finally {
      _prefsOperationInProgress = false;
    }
  }

  // Configuration properties
  static double shakeThreshold = 2.7;
  static Duration cooldownDuration = const Duration(seconds: 30);
  static bool notificationsEnabled = true;
  static bool soundEnabled = true;
  static bool vibrationEnabled = true;

  static bool _taskDataCallbackRegistered = false;
  static const String pendingEmergencyKey = 'emergency_pending_v2';
  static const String pendingEmergencyTimestampKey =
      'emergency_pending_timestamp_v2';
  static bool _navigationInProgress = false;

  // Configuration options
  static Future<void> updateConfiguration({
    double? threshold,
    Duration? cooldown,
    bool? notifications,
    bool? sound,
    bool? vibration,
  }) async {
    try {
      await _runWithPrefsLock<void>((prefs) async {
        if (threshold != null) {
          shakeThreshold = threshold;
          await prefs.setDouble('shake_threshold', threshold);
        }

        if (cooldown != null) {
          cooldownDuration = cooldown;
          await prefs.setInt('cooldown_seconds', cooldown.inSeconds);
        }

        if (notifications != null) {
          notificationsEnabled = notifications;
          await prefs.setBool('notifications_enabled', notifications);
        }

        if (sound != null) {
          soundEnabled = sound;
          await prefs.setBool('sound_enabled', sound);
        }

        if (vibration != null) {
          vibrationEnabled = vibration;
          await prefs.setBool('vibration_enabled', vibration);
        }
      });
    } catch (e) {
      debugPrint('⚠️ Error al guardar configuración: $e');
      // Continuar con los valores en memoria aunque no se guarden
    }
  }

  // Start background service
  static Future<void> start(GlobalKey<NavigatorState>? navigatorKey) async {
    _navigatorKey = navigatorKey;

    try {
      debugPrint('🔄 Inicializando sistema de emergencia...');
      await _initNotification();
      await requestEmergencyPermissions();

      if (!_taskDataCallbackRegistered) {
        FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
        _taskDataCallbackRegistered = true;
      }

      final bool isRunning = await FlutterForegroundTask.isRunningService;
      debugPrint('Estado anterior del servicio: $isRunning');

      final result = isRunning
          ? await FlutterForegroundTask.restartService()
          : await FlutterForegroundTask.startService(
              notificationTitle: 'Fiuu Assistant - Modo Emergencia',
              notificationText: 'Monitoreo de agitación activo.',
              callback: startCallback,
              serviceTypes: [ForegroundServiceTypes.specialUse],
              notificationInitialRoute: '/emergency',
            );

      debugPrint('Resultado del servicio: ${result.runtimeType} - $result');
      debugPrint(
        'Estado actual del servicio: '
        '${await FlutterForegroundTask.isRunningService}',
      );
    } catch (error, stackTrace) {
      debugPrint('Error al iniciar servicio: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> startIfEnabled(
    GlobalKey<NavigatorState>? navigatorKey,
  ) async {
    try {
      final enabled = await _runWithPrefsLock<bool>((prefs) async {
        return prefs.getBool('emergency_service_enabled') ?? false;
      });
      if (enabled) {
        await start(navigatorKey);
      }
    } catch (e) {
      debugPrint('⚠️ Error al verificar si el servicio está habilitado: $e');
    }
  }

  /// Calcular la magnitud del vector de aceleración
  static double _calculateMagnitude(AccelerometerEvent event) {
    double gX = event.x / 9.806665;
    double gY = event.y / 9.806665;
    double gZ = event.z / 9.806665;
    return sqrt(gX * gX + gY * gY + gZ * gZ);
  }

  static Future<void> _triggerEmergency() async {
    if (_isEmergencyActive) return;
    _isEmergencyActive = true;

    try {
      await _runWithPrefsLock<void>((prefs) async {
        await prefs.setBool(pendingEmergencyKey, true);
        await prefs.setInt(
          pendingEmergencyTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      });
      await _showEmergencyNotification();
      debugPrint("⚠️ EMERGENCY MODE ACTIVATED!");

      try {
        await EmergencyAlertService.sendCurrentLocation();
        await _showEmergencySmsResult(sent: true);
      } catch (error, stackTrace) {
        debugPrint('No se pudo enviar el SMS de emergencia: $error');
        debugPrintStack(stackTrace: stackTrace);
        await _showEmergencySmsResult(sent: false);
      }

      final bool appIsForeground =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      final navigator = _navigatorKey?.currentState;

      if (appIsForeground && navigator != null && navigator.mounted) {
        debugPrint('📱 Aplicación activa: abriendo emergencia');
        await _clearPendingEmergency();
        if (!_navigationInProgress) {
          _navigationInProgress = true;
          unawaited(
            navigator.pushNamed('/emergency').whenComplete(() {
              _navigationInProgress = false;
            }),
          );
        }
      } else {
        debugPrint(
          '📱 Aplicación en segundo plano: '
          'emergencia pendiente de recuperar',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Error activando emergencia: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      await Future.delayed(const Duration(seconds: 30));
      _isEmergencyActive = false;
    }
  }

  static Future<void> _clearPendingEmergency() async {
    try {
      await _runWithPrefsLock<void>((prefs) async {
        await prefs.setBool(pendingEmergencyKey, false);
        await prefs.remove(pendingEmergencyTimestampKey);
      });
      debugPrint('✅ Estado de emergencia pendiente eliminado');
    } catch (e) {
      debugPrint('⚠️ Error al limpiar emergencia pendiente: $e');
    }
  }

  static Future<void> _showEmergencyNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Notifications',
      channelDescription: 'Notifications for emergency mode',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      enableVibration: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: 888,
      title: '⚠️ EMERGENCY MODE ACTIVATED!',
      body: 'Shake detected! Emergency actions triggered',
      notificationDetails: details,
      payload: 'emergency',
    );
  }

  static Future<void> _showEmergencySmsResult({required bool sent}) async {
    await _notifications.show(
      id: 889,
      title: sent ? 'Ubicación enviada' : 'No se pudo enviar la ubicación',
      body: sent
          ? 'Se envió un SMS al contacto de emergencia.'
          : 'Revisa la ubicación, el contacto y la conexión a internet.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'emergency_channel',
          'Emergency Notifications',
          channelDescription: 'Notifications for emergency mode',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> requestFullScreenPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final result = await androidImplementation
        ?.requestFullScreenIntentPermission();
    print('result fullScreen Intent: $result');
  }

  static Future<void> requestEmergencyPermissions() async {
    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static Future<void> _initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestCriticalPermission: false,
      ),
      linux: const LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      ),
      macOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestCriticalPermission: false,
      ),
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'emergency') {
          _navigatorKey?.currentState?.pushNamed('/emergency');
        }
      },
    );
    debugPrint('Notificaciones inicializadas correctamente');
  }

  static Future<void> stop() async {
    if (_taskDataCallbackRegistered) {
      FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
      _taskDataCallbackRegistered = false;
    }

    final result = await FlutterForegroundTask.stopService();
    debugPrint('Resultado al detener servicio: $result');
  }

  static void _onReceiveTaskData(Object data) {
    debugPrint('📨 Datos recibidos desde el servicio: $data');
    if (data is! Map) return;

    switch (data['event']) {
      case 'handler_started':
        debugPrint('✅ El manejador de emergencia está funcionando');
        break;

      case 'emergency':
        debugPrint('🚨 Evento de emergencia recibido');
        unawaited(_triggerEmergency());
        break;

      default:
        debugPrint('Evento desconocido: ${data['event']}');
    }
  }

  static Future<void> loadConfiguration() async {
    try {
      await _runWithPrefsLock<void>((prefs) async {
        shakeThreshold = prefs.getDouble('shake_threshold') ?? 2.7;
        cooldownDuration = Duration(
          seconds: prefs.getInt('cooldown_seconds') ?? 30,
        );
        notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        soundEnabled = prefs.getBool('sound_enabled') ?? true;
        vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      });
    } catch (e) {
      debugPrint('⚠️ Error al cargar configuración: $e');
      // Usar valores por defecto
      shakeThreshold = 2.7;
      cooldownDuration = const Duration(seconds: 30);
      notificationsEnabled = true;
      soundEnabled = true;
      vibrationEnabled = true;
    }
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(EmergencyTaskHandler());
}

class EmergencyTaskHandler extends TaskHandler {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    int _sensorEventsLogged = 0;

    // Inicializaciones o lógica cuando arranca la tarea en segundo plano
    debugPrint("🚀 EmergencyTaskHandler iniciado");
    FlutterForegroundTask.sendDataToMain({'event': 'handler_started'});

    try {
      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          final now = DateTime.now();
          final magnitude = EmergencyService._calculateMagnitude(event);

          if (_sensorEventsLogged < 10) {
            debugPrint('📱 Aceleración: ${magnitude.toStringAsFixed(2)} G');
            _sensorEventsLogged++;
          }

          if (magnitude > EmergencyService.shakeThreshold) {
            if (_lastShakeTime != null &&
                now.difference(_lastShakeTime!) < const Duration(seconds: 1)) {
              return;
            }

            _lastShakeTime = now;
            debugPrint(
              '🚨 AGITACIÓN DETECTADA EN SERVICIO: '
              '${magnitude.toStringAsFixed(2)} G',
            );

            FlutterForegroundTask.sendDataToMain({
              'event': 'emergency',
              'magnitude': magnitude,
              'timestamp': now.microsecondsSinceEpoch,
            });
          }
        },
        onError: (error) {
          debugPrint('Error del acelerómetro en servicio: $error');
        },
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Error iniciando sensor: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Aquí puedes poner lógica periódica si lo necesitas
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Limpieza cuando el servicio se detiene
    debugPrint('🛑 EmergencyTaskHandler detenido');
    await _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  @override
  void onNotificationButtonPressed(String id) {
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationPressed() {
    // Acción al tocar la notificación en la barra de estado
    debugPrint('Notificación del servicio seleccionada');
  }
}
