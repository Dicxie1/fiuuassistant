import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MoodAuthGuardScreen extends StatefulWidget {
  const MoodAuthGuardScreen({super.key});

  @override
  State<MoodAuthGuardScreen> createState() => _MoodAuthGuardScreen();
}

class _MoodAuthGuardScreen extends State<MoodAuthGuardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint("Error al inicializar Google Sing-In $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId:
            "100913023077-mkib000k17f6s0h543r90gvh8ff53uap.apps.googleusercontent.com",
      );
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      debugPrint("User selected account: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      debugPrint(
        "'Retrieved Google ID token: ${googleAuth.idToken != null ? "SUCCESS" : "NULL"}",
      );
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint('idToken== null');
        return;
      }
      final String accessToken = clientAuth.accessToken;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      debugPrint("Firebase credential created");
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      _showSnackBar('Conexión cancelada o rechazada.', Colors.orangeAccent);
      debugPrint(
        "Error de Google Sign In: código ${e.code.name} - ${e.description}",
      );
    } catch (e) {
      _showSnackBar('Error al conectar con Google.', Colors.redAccent);
      debugPrint("Error inesperado de inicio de sesión: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      // Nota: Aquí se vincula la lógica con el paquete sign_in_with_apple
      _showSnackBar('Conectando con Apple ID...', const Color(0xFF58A6A6));
    } catch (e) {
      _showSnackBar('Error al conectar con Apple.', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openEmailLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que se desplace hacia arriba con el teclado
      backgroundColor: Colors.transparent,
      builder: (context) => const _EmailLoginBottomSheet(),
    );
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F7),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_person_outlined,
              size: 80,
              color: Color(0xFF4A6A6A),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tu Diario emocional",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              'Para registrar tu estado de ánimo diario y cuidar tu bienestar, necesitas iniciar sesión en la plataforma.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _openEmailLoginSheet,
              icon: const Icon(Icons.login_rounded),
              label: const Text("iniciar Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58A6A6),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "o iniciar con",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF58A6A6)),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 30,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        'Google',
                        style: TextStyle(
                          color: Color(0xFF4A6A6A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _signInWithApple,
                      icon: const Icon(
                        Icons.apple,
                        size: 30,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Apple',
                        style: TextStyle(
                          color: Color(0xFF4A6A6A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmailLoginBottomSheet extends StatefulWidget {
  const _EmailLoginBottomSheet();

  @override
  State<_EmailLoginBottomSheet> createState() => _EmailLoginBottomSheetState();
}

class _EmailLoginBottomSheetState extends State<_EmailLoginBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggingIn = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoggingIn = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context); // Cierra el BottomSheet si tiene éxito
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error de autenticación.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Correo o contraseña incorrectos.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery evita que el teclado del teléfono tape los inputs
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra indicadora de arrastre superior
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Ingresa tus datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6A6A),
                ),
              ),
              const SizedBox(height: 15),

              // Input: Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF4A6A6A),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 8),

              // Input: Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF4A6A6A),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF4A6A6A),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => (value == null || value.length < 6)
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 24),

              // Botón de Confirmación
              _isLoggingIn
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF58A6A6),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6A6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
