import 'package:fiuuassistant/features/courses_screen/data/models/topic_model.dart';
import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_reader_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final CourseModel course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // 1. El FutureBuilder envuelve todo el contenido que depende de Firebase
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('courses')
          .doc(course.id)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(course.title)),
            body: const Center(
              child: Text('Error al cargar detalles del curso'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(course.title)),
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

        // 2. Retornamos el Scaffold aquí, ahora que ya sabemos si hay módulos
        return Scaffold(
          appBar: AppBar(title: Text(course.title)),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        return ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 72,
                            right: 16,
                          ),
                          leading: const Icon(
                            Icons.play_circle_outline,
                            size: 20,
                            color: Colors.teal,
                          ),
                          title: Text(
                            topic.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onTap: () {},
                        );
                      }).toList(),
                    );
                  }, childCount: modules.length),
                ),
              // Agregamos un padding final para que el botón no tape el último ítem
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          // 3. El botón ahora recibirá el valor correcto de hasModules
          bottomNavigationBar: hasModules
              ? _buildFixedBottomButton(context, fullCourse)
              : null,
        );
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
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        20,
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
      child: ElevatedButton(
        onPressed: () {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseReaderScreen(
                topics: allTopicsWithContent,
                initialIndex: 0,
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
    );
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
