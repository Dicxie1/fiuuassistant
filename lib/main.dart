import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/emergency_mode/presentation/screens/emergency_mode_screen.dart';
import 'package:fiuuassistant/screen/navigation_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:fiuuassistant/features/admin/presentation/widgets/web_auth_gate.dart';
import 'package:fiuuassistant/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:fiuuassistant/features/emergency_mode/services/shack_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();

    // Iniciar escucha global de agitación brusca
    if (!kIsWeb) {
      ShakService.startListening(
        shakeThreshold: 2.7, // Ajusta la intensidad requerida para activar
        onShake: () {
          // Abrir la pantalla de emergencia sin importar dónde esté el usuario
          _navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const EmergencyModeScreen(),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    ShakService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:  _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Fiuu Assistant',
      initialRoute: '/',
      routes: {'/': (context) => MainWrapper()},
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
