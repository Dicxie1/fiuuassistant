import 'package:fiuuassistant/features/profile/data/datasources/emergency_contact_remote_data_source.dart';
import 'package:fiuuassistant/features/profile/data/repositories/emergency_contact_repository_imp.dart';
import 'package:fiuuassistant/features/profile/domain/entities/emergency_contact.dart';
import 'package:fiuuassistant/features/profile/domain/usecases/save_emergency_contact.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fiuuassistant/features/progress/presentation/widgets/progress_card.dart';
import 'package:fiuuassistant/features/progress/domain/entities/user_progress.dart';
import 'package:fiuuassistant/features/progress/domain/usecases/get_user_progress.dart';
import 'package:fiuuassistant/features/profile/domain/usecases/get_emergency_contact.dart';
import 'package:fiuuassistant/features/profile/domain/usecases/save_emergency_contact.dart';
import 'package:fiuuassistant/features/progress/data/repositories/progress_repository_imp.dart';
import 'package:fiuuassistant/features/progress/data/datasources/progress_remote_data_source.dart';
import 'package:fiuuassistant/features/profile/data/repositories/emergency_contact_repository_imp.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  UserProgress? _userProgress;
  bool _isLoadingProgress = true;
  late ProgressRepositoryImp _progressRepository;
  late GetUserProgress _getUserProgress;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmergencyContact? _emergencyContact;
  bool _isLoadingEmergencyContact = true;
  late EmergencyContactRepositoryImpl _emergencyContactRepository;
  late GetEmergencyContact _getEmergencyContact;
  late SaveEmergencyContact _saveEmergencyContact;

  @override
  void initState() {
    super.initState();
    final dataSource = ProgressRemoteDataSourceImp(FirebaseFirestore.instance);
    _progressRepository = ProgressRepositoryImp(dataSource);
    _getUserProgress = GetUserProgress(_progressRepository);
    _loadUserProgress();

    final emergencyContactDataSource = EmergencyContactRemoteDataSource(
      FirebaseFirestore.instance,
    );
    _emergencyContactRepository = EmergencyContactRepositoryImpl(
      remoteDataSource: emergencyContactDataSource,
    );
    _saveEmergencyContact = SaveEmergencyContact(_emergencyContactRepository);
    _getEmergencyContact = GetEmergencyContact(_emergencyContactRepository);
    _loadEmergencyContact();
  }

  Future<void> _loadEmergencyContact() async {
    if (_user != null) {
      try {
        _emergencyContact = await _getEmergencyContact.call(_user.uid);
      } catch (e) {
        // Si hay error, crear contacto de emergencia por defecto
        _emergencyContact = null;
      } finally {
        if (mounted) {
          setState(() => _isLoadingEmergencyContact = false);
        }
      }
    } else {
      setState(() => _isLoadingEmergencyContact = false);
    }
  }

  Future<void> _showEmergencyContactDialog() async {
    if(_user == null || _user.uid.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede guardar el contacto de emergencia sin un usuario válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();
    if (_emergencyContact != null) {
      nameController.text = _emergencyContact!.name;
      phoneController.text = _emergencyContact!.phone;
      relationshipController.text = _emergencyContact!.relationship;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _emergencyContact == null
                ? 'Agregar Contacto de Emergencia'
                : 'Editar Contacto de Emergencia',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ingrese el nombre',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    hintText: 'Ej. +505 5423 6532',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-9+() -]+$')),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    labelText: 'Relación',
                    hintText: 'Ej. Padre, Madre, Esposo(a)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF58A6A6),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El nombre es obligatorio.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El teléfono es obligatorio.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (relationshipController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La relación es obligatoria.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                try {
                  final contact = EmergencyContact(
                    id: _emergencyContact?.id ?? "",
                    userId: _user!.uid,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    relationship: relationshipController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  if(contact.userId.isEmpty){
                    throw Exception('El ID del usuario no puede estar vacío.');
                  }
                  await _saveEmergencyContact.call(contact);
                  if (mounted) {
                    setState(() {
                      _emergencyContact = contact;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contacto de emergencia guardado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar el contacto: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _user?.displayName ?? "Usuario Invitado";
    final String email = _user?.email ?? "Sin correo electrónico";
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F7),
      appBar: AppBar(
        title: Text("Fiuu App"),
        backgroundColor: Color(0xFF58A6A6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF58A6A6),
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  Stack(
                    alignment: AlignmentGeometry.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundImage: _user?.photoURL != null
                              ? NetworkImage(_user!.photoURL!)
                              : null,
                          child: _user?.photoURL == null
                              ? const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      if (_user != null)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (_user != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Cursos", "4", Icons.book_outlined),
                    _buildDivider(),
                    _buildStatItem(
                      "Racha",
                      "5 días",
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      "XP Total",
                      "1350",
                      Icons.start,
                      Colors.amber,
                    ),
                  ],
                ),
              ),
            if (_user != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Racha",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    if (_user != null) ...[
                      if (_isLoadingProgress)
                        const CircularProgressIndicator()
                      else
                        ProgressCard(progress: _userProgress!),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "General",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_user == null)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "o iniciar con",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                onPressed: () {},
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                        SizedBox(height: 24),
                      ],
                    ),

                  _buildProfileCard([
                    if (_user != null)
                      _buildTitle(
                        icon: Icons.notifications_none_outlined,
                        title: 'Notificaciones',
                        subtitle: 'Recordatorio de lectura',
                        onTap: () {},
                      ),
                    if (_user != null)
                      _buildTitle(
                        icon: Icons.quick_contacts_dialer_outlined,
                        title: 'Contactos de Emergencia',
                        subtitle: 'Configura tu contacto de emergencia',
                        onTap: _showEmergencyContactDialog,
                      ),
                    _buildTitle(
                      icon: Icons.privacy_tip_outlined,
                      title: "Politica de Privacidad",
                      subtitle: "Uso de datos y término de servicios",
                      onTap: () {},
                    ),
                    _buildTitle(
                      icon: Icons.info_outline,
                      title: "Sobre la App",
                      subtitle: "Version 1.0.0 FiuuAssistant",
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "FiuuAssitant",
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                            Icons.school,
                            size: 40,
                            color: Color(0xFF58A6A6),
                          ),
                          children: [
                            const Text(
                              "Asistente educativo para la apoyo de gestion emocional y aprendizaje de cursos",
                            ),
                          ],
                        );
                      },
                    ),
                    if (_user != null)
                      _buildTitle(
                        icon: Icons.logout,
                        title: 'Cerrar Sessión',
                        titleColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: _signOut,
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // close Session function
  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Sing with Google function
  Future<void> _singWithGoogle() async {
    try {
      final googleSingIn = GoogleSignIn.instance;
      await googleSingIn.initialize(
        serverClientId:
            "100913023077-mkib000k17f6s0h543r90gvh8ff53uap.apps.googleusercontent.com",
      );
      final GoogleSignInAccount googleUser = await googleSingIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);
      final String? token = googleAuth.idToken;
      if (token != null) {
        return;
      }
      final accessToken = clientAuth.accessToken;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: token,
        accessToken: accessToken,
      );
      await _auth.signInWithCredential(credential);
    } on GoogleAuthCredential catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión con Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión con Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatItem(
    String item,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? const Color(0xFF1A237E), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(item, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTitle({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF1A237E)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _loadUserProgress() async {
    if (_user != null) {
      try {
        _userProgress = await _getUserProgress.call(_user.uid);
      } catch (e) {
        // Si hay error, crear progreso por defecto
        _userProgress = UserProgress(
          userId: _user.uid,
          totalXP: 0,
          currentLevel: 1,
          currentStreak: 0,
          longestStreak: 0,
          lastActivityDate: DateTime.now(),
          courses: [],
        );
      } finally {
        if (mounted) {
          setState(() => _isLoadingProgress = false);
        }
      }
    } else {
      setState(() => _isLoadingProgress = false);
    }
  }
}
