import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/course_model.dart'; // Importa tu modelo
import '../widget/course_card_widget.dart'; // Tu widget de tarjeta

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con patrón (se mantiene igual)
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/lined-paper.png',
              repeat: ImageRepeat.repeat,
              color: const Color(0xFF00ACC1),
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

                          // Retornamos tu widget refactorizado
                          return CoursecardWidget(course: course);
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
}
