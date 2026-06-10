import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:fiuuassistant/features/courses_screen/data/datasources/course_remote_data_source.dart';
import 'package:fiuuassistant/features/admin/presentation/widgets/edit_course_dialog.dart';
import 'courses_content_screen.dart';

class CoursesManagerScreen extends StatefulWidget {
  final List<CourseModel> courses;
  const CoursesManagerScreen({super.key, this.courses = const []});

  @override
  State<CoursesManagerScreen> createState() => _CoursesManagerScreenState();
}

class _CoursesManagerScreenState extends State<CoursesManagerScreen> {
  late final CourseRemoteDataSourceImpl courseRemoteDataSource;
  @override
  void initState() {
    super.initState();
    courseRemoteDataSource = CourseRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Panel de Gestión de Cursos",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<CourseModel>>(
              stream: courseRemoteDataSource.getCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error al cargar cursos: ${snapshot.error}"),
                  );
                }
                final courses = snapshot.data ?? [];
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay cursos disponibles"));
                }
                return GridView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return _buildCard(context, index, courses[index]);
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 400,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index, CourseModel course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias, // Redondea la imagen con el borde del Card
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGEN DEL ENCABEZADO (Estilo Marketplace)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://picsum.photos/id/${index + 50}/800/400',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: const Text(
                "Nivel: Grado",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // 2. DETALLES DEL CURSO
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Docente: ${course.instructor} | Duración: ${course.duration}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),
                // 3. BOTONES DE ACCIÓN SOLICITADOS
                Row(
                  children: [
                    // Botón de Previsualización Móvil
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Lógica para ver versión móvil
                        },
                        icon: const Icon(Icons.phone_android),
                        label: const Text("Vista Móvil"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.indigo),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón de Editar Contenidos
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: ()  async{
                          final updateCourse = await  showDialog<CourseModel>(
                            context: context,
                            builder: (context) =>
                                EditCourseDialog(course: course),
                          );
                          if(updateCourse != null){
                            try{
                              await courseRemoteDataSource.updateCourse(updateCourse);
                              if(context.mounted){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Curso actualizado correctamente"))
                                );
                              }
                            } catch(e){
                              if(context.mounted){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error al actualizar: $e"))
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.edit_note),
                        label: const Text("Editar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navegación a la gestión de arquitectura del curs
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CoursesContentScreen(course: course),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.account_tree_outlined,
                        ), // Icono que representa jerarquía
                        label: const Text("Contenidos"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .teal
                              .shade700, // Un color distinto para diferenciar gestión de edición
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
