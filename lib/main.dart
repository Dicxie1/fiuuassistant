import 'package:fiuuassistant/screen/navigation_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:fiuuassistant/features/admin/presentation/widgets/web_auth_gate.dart';
import 'package:fiuuassistant/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
