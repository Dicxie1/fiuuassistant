import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/progress/presentation/widgets/progress_card.dart';
import 'package:fiuuassistant/features/progress/domain/entities/user_progress.dart';
import 'package:fiuuassistant/features/progress/domain/usecases/get_user_progress.dart';
import 'package:fiuuassistant/features/progress/data/repositories/progress_repository_imp.dart';
import 'package:fiuuassistant/features/progress/data/datasources/progress_remote_data_source.dart';

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
  @override
  void initState() {
    super.initState();
    final dataSource = ProgressRemoteDataSourceImp(FirebaseFirestore.instance);
    _progressRepository = ProgressRepositoryImp(dataSource);
    _getUserProgress = GetUserProgress(_progressRepository);
    _loadUserProgress();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _user?.displayName ?? "";
    final String email = _user?.email ?? "";
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
                  _buildStatItem("XP Total", "1350", Icons.start, Colors.amber),
                ],
              ),
            ),
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
                  const Text(
                    "General",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProfileCard([
                    _buildTitle(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notificaciones',
                      subtitle: 'Recordatorio de lectura',
                      onTap: () {},
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
                    _buildTitle(
                      icon: Icons.logout,
                      title: 'Cerrar Sessión',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () {},
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
