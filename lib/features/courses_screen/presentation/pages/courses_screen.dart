import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widget_previews.dart';
import '../../data/models/course_model.dart'; // Importa tu modelo
import '../widget/course_card_widget.dart'; // Tu widget de tarjeta
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiuuassistant/features/courses_screen/data/repositories/enrollment_repository.dart';
import 'package:fiuuassistant/features/courses_screen/presentation/pages/course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  @Preview(
    name: 'CoursesScreenPreview',
    textScaleFactor: 1.0,
    brightness: Brightness.light,
  )
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CoursesScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late EnrollmentRepositoryImp _enrollmentRepository;
  List<CourseModel> _availableCourses = [];
  List<String> _enrolledCourses = [];
  bool _isLoading = false;

  Future<void> _loadData() async {
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .get();
      if (mounted) {
        _availableCourses = coursesSnapshot.docs
            .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
            .toList();
      }
      _enrolledCourses = await _enrollmentRepository.getEnrollmentCourses(
        _user.uid,
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar cursos: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _enrollmentRepository = EnrollmentRepositoryImp(FirebaseFirestore.instance);
    _loadData();
  }

  Future<void> _enrollInCourse(String courseId) async {
    if (_user == null) {
      debugPrint("Usuario no autenticado");
      return;
    }
    debugPrint(
      "Intentando matricular al usuario ${_user.uid} en el curso $courseId",
    );
    setState(() => _isLoading = true);
    try {
      await _enrollmentRepository.enroll(_user.uid, courseId);
      _enrolledCourses.add(courseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Matriculado con Exito"),
            backgroundColor: Color(0xFF58A6A6),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al matricularse $err")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return Stack(
      children: [
        // Fondo con patrón (se mantiene igual)
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image(
              image: const AssetImage("assets/img/asfalt_dark.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text(
                    'Cursos Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  style: TextStyle(color: Color(0xFF4A6A6A), fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Buscar cursos",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 18, right: 12),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF4A6A6A),
                        size: 24,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 236, 244, 246),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Implementación con Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Accedemos a la colección que ya tienes configurada
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error al cargar cursos'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Convertimos los documentos a nuestra lista de entidades
                      final coursesDocs = snapshot.data!.docs;

                      if (coursesDocs.isEmpty) {
                        return const Center(
                          child: Text('No hay cursos disponibles actualmente.'),
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: coursesDocs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          // Usamos el model para transformar el JSON de Firebase
                          final courseData =
                              coursesDocs[index].data() as Map<String, dynamic>;
                          final course = CourseModel.fromFirestore(
                            courseData,
                            coursesDocs[index].id,
                          );
                          final courseEnroll = coursesDocs[index];
                          final isEnrolled = _enrolledCourses.contains(
                            courseEnroll.id,
                          );
                          // Retornamos tu widget refactorizado
                          return CourseCardWidget(
                            course: course,
                            isEnrolled: isEnrolled,
                            onEnroll: isEnrolled
                                ? null
                                : () {
                                    debugPrint(
                                      "🔍 DEBUG: course.id = '${course.id}'",
                                    );
                                    debugPrint(
                                      "🔍 DEBUG: _user?.uid = '${_user?.uid}'",
                                    );
                                    _enrollInCourse(course.id);
                                  },
                            onTap: isEnrolled
                                ? () => _navigateToCourse(course)
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToCourse(CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CourseDetailsScreen(course: course, isEnrolled: true),
      ),
    );
  }
}
