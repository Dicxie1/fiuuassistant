import 'package:fiuuassistant/features/courses_screen/data/models/topic_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/courses_screen/data/repositories/enrollment_repository.dart';
import 'course_reader_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;
  final bool isEnrolled;
  const CourseDetailsScreen({
    super.key,
    required this.course,
    this.isEnrolled = false,
  });
  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreen();
}

class _CourseDetailsScreen extends State<CourseDetailsScreen> {
  late EnrollmentRepositoryImp _enrollmentRepository;
  bool _isEnrolled = false;
  bool _isLoading = true;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _enrollmentRepository = EnrollmentRepositoryImp(FirebaseFirestore.instance);
    _checkEnrollment();
  }

  Future<void> _checkEnrollment() async {
    if (_currentUser != null) {
      _isEnrolled = await _enrollmentRepository.isEnrolled(
        _currentUser.uid,
        widget.course.id,
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _enrollInCourse() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para matricularte')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _enrollmentRepository.enroll(user.uid, widget.course.id);
      _isEnrolled = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Matriculado con éxito!'),
          backgroundColor: Color(0xFF58A6A6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al matricularse: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.course.title)),
            body: const Center(
              child: Text('Error al cargar detalles del curso'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.course.title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final fullCourse = CourseModel.fromFirestore(
          snapshot.data!.data() as Map<String, dynamic>,
          snapshot.data!.id,
        );

        // Usamos una lista dinámica para evitar errores de casteo previos
        final modules = List<dynamic>.from(fullCourse.module);
        final bool hasModules = modules.isNotEmpty;
        return StreamBuilder<DocumentSnapshot>(
          stream: currentUser != null
              ? FirebaseFirestore.instance
                    .collection('user_progress')
                    .doc(currentUser.uid)
                    .snapshots()
              : const Stream.empty(),
          builder: (context, progressSnapshot) {
            List<String> completedTopics = [];
            if (progressSnapshot.hasData && progressSnapshot.data!.exists) {
              final progressData =
                  progressSnapshot.data!.data() as Map<String, dynamic>?;
              if (progressData != null && progressData['courses'] != null) {
                final coursesList = progressData['courses'] as List<dynamic>;
                final currentCourseProgress = coursesList.firstWhere(
                  (c) => c['courseId'] == widget.course.id,
                  orElse: () => null,
                );
                if (currentCourseProgress != null &&
                    currentCourseProgress['completedTopics'] != null) {
                  completedTopics = List<String>.from(
                    currentCourseProgress['completedTopics'],
                  );
                }
              }
            }
            int topicIndex = 0;
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.course.title),
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCourseMeta(fullCourse),
                          const SizedBox(height: 20),
                          const Text(
                            "Contenido del programa",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!hasModules)
                    const SliverFillRemaining(
                      child: Center(child: Text('No hay módulos disponibles')),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final module = modules[index];
                        return ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1A237E),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text("Módulo ${index + 1}: ${module.title}"),
                          subtitle: Text("${module.topics.length} Temas"),
                          children: module.topics.map<Widget>((topic) {
                            final topicKey =
                                "${widget.course.id}_${topic.title}";
                            int currentTopicIndex = topicIndex;
                            topicIndex++;
                            bool isTopicRead = completedTopics.contains(
                              topicKey,
                            );

                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 72,
                                right: 16,
                              ),
                              leading: Icon(
                                isTopicRead
                                    ? Icons.play_circle
                                    : Icons.play_circle_outline,
                                size: 20,
                                color: isTopicRead ? Colors.teal : Colors.grey,
                              ),
                              title: Text(
                                topic.title,
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: Icon(
                                isTopicRead
                                    ? Icons.check_circle
                                    : Icons.check_circle_outlined,
                                size: 18,
                                color: isTopicRead ? Colors.teal : Colors.grey,
                              ),
                              onTap: isTopicRead
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CourseReaderScreen(
                                                topics: _getAllTopicContet(
                                                  widget.course,
                                                ),
                                                courseId: widget.course.id,
                                                initialIndex: currentTopicIndex,
                                              ),
                                        ),
                                      );
                                    }
                                  : () {},
                            );
                          }).toList(),
                        );
                      }, childCount: modules.length),
                    ),
                  // Agregamos un padding final para que el botón no tape el último ítem
                ],
              ),
              // 3. El botón ahora recibirá el valor correcto de hasModules
              bottomNavigationBar: hasModules
                  ? _buildFixedBottomButton(context, fullCourse)
                  : null,
            );
          },
        );
        // 2. Retornamos el Scaffold aquí, ahora que ya sabemos si hay módulos
      },
    );
  }

  // --- Mantenemos tus métodos auxiliares igual ---
  Widget _buildCourseMeta(CourseModel course) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _metaIcon(Icons.person, course.instructor),
        _metaIcon(Icons.timer, course.duration),
        _metaIcon(Icons.star, course.rating.toString()),
      ],
    );
  }

  Widget _metaIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00ACC1)),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFixedBottomButton(BuildContext context, CourseModel course) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Ajuste para el área segura
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: ElevatedButton(
          onPressed: () {
            List<TopicModel> allTopicsWithContent = _getAllTopicContet(course);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseReaderScreen(
                  topics: allTopicsWithContent,
                  initialIndex: 0,
                  courseId: course.id,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54), // "Expands" el botón
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "INICIAR LECTURA",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  List<TopicModel> _getAllTopicContet(CourseModel course) {
    List<TopicModel> allTopicsWithContent = [];
    for (var i = 0; i < course.module.length; i++) {
      var module = course.module[i];
      var topicsInModule = module.topics;

      String unitLabel = "Unidad ${_toRoman(i + 1)}: ${module.title}";
      for (int j = 0; topicsInModule.length > j; j++) {
        bool isLastTopic = (j == topicsInModule.length - 1);

        allTopicsWithContent.add(
          module.topics[j].copyWith(
            parentModuleName: unitLabel,
            checkpointQuestions: isLastTopic ? module.questions : null,
          ),
        );
      }
    }
    return allTopicsWithContent;
  }

  String _toRoman(int number) {
    final romans = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
    ];
    return (number > 0 && number <= 10)
        ? romans[number - 1]
        : number.toString();
  }
}
