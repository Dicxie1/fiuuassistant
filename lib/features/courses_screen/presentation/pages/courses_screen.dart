import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/course_model.dart'; // Importa tu modelo
import '../widget/course_card_widget.dart'; // Tu widget de tarjeta

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

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
