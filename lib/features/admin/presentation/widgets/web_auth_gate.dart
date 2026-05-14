import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/admin_dashboard.dart';
import '../pages/web_login_screen.dart';

class WebAuthGate extends StatelessWidget {
  final Widget child;
  const WebAuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Mientras verifica el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si el usuario está autenticado, mostramos el Panel Admin
        if (snapshot.hasData) {
          return const AdminDashboard();
        }

        // 3. Si no hay datos, mostramos la pantalla de Login para Web
        return const WebLoginScreen();
      },
    );
  }
}