import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/courses_screen/data/datasources/course_remote_data_source.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/question_model.dart';
import '../widgets/topic_edit_widget.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/module_model.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/topic_model.dart';
import '../widgets/question_edit_widget.dart';

class CoursesContentScreen extends StatefulWidget {
  final CourseModel course;
  const CoursesContentScreen({super.key, required this.course});

  @override
  State<CoursesContentScreen> createState() => _CoursesContentScreenState();
}

class _CoursesContentScreenState extends State<CoursesContentScreen> {
  late CourseModel _localCourse;
  String? selectedItemId;
  String? selectedItemType; // "topic", "video", "quiz"
  String? selectedItemTitle;
  dynamic currentSelectedTopic;
  bool _isCreatingNewTopic = false;
  String? _activeModuleIdForceCreation;
  bool _isSaving = false;
  List<QuestionModel> activeQuizQuestions = [];
  dynamic
  selectedTopicData; // Para saber a qué módulo pertenece el quiz seleccionado, útil para agregar preguntas nuevas al módulo correcto
  @override
  void initState() {
    super.initState();
    // 2. Inicializamos nuestra variable local con el curso que viene por parámetro
    _localCourse = widget.course;
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: Intentando leer /courses/${widget.course.id}/module");

    final List<dynamic> modulesList = _localCourse.module;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestión de Contenidos",
              style: TextStyle(fontSize: 14, color: Colors.indigo.shade100),
            ),
            Text(
              widget.course.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        actions: [
          TextButton.icon(
            onPressed: () => _addNewModule(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Nuevo Módulo",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          // PANEL IZQUIERDO: Árbol de contenidos (Módulos y Temas)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade200,
              child: modulesList.isEmpty
                  ? _buildEmptyState(context)
                  : ListView(
                      children: modulesList.map((module) {
                        // Extraemos temas y preguntas de este módulo específico
                        final List<TopicModel> topicsList = module.topics ?? [];
                        final List<QuestionModel> moduleQuestions =
                            module.questions ?? [];

                        // Filtramos por si vienen temas vacíos en la base de datos como en el ejemplo
                        final List<TopicModel> validTopics = topicsList
                            .where(
                              (t) =>
                                  t.title.toString().isNotEmpty,
                            )
                            .toList();

                        return ExpansionTile(
                          leading: const Icon(
                            Icons.folder,
                            color: Colors.indigo,
                          ),
                          // Muestra: "Módulo Historia de la psicología", "Módulo Emociones y Sentimientos", etc.
                          title: Text(
                            "Módulo  ${module.title}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          children: [
                            // 1. LISTAR LOS TEMAS NORMALES (1.1, 1.2, 1.3...)
                            ...validTopics.asMap().entries.map((entry) {
                              int tIndex = entry.key;
                              var topic = entry.value;

                              // Si el topic ya trae un sub-orden (ej: "1") lo usamos, si no, usamos el índice correlativo
                              String subOrder =
                                  (topic.order.toString().isNotEmpty)
                                  ? topic.order.toString()
                                  : "${tIndex + 1}";

                              return _buildSubItem(
                                "${module.order}.$subOrder", // Genera "1.1", "1.2", etc.
                                topic.title,
                                topic.hasTopics
                                    ? Icons.description
                                    : Icons.edit_document,
                                isQuiz: false,
                                onTap: () {
                                  setState(() {
                                    selectedItemId =
                                        "${module.order}.$subOrder";
                                    selectedItemType = "topic";
                                    selectedItemTitle = topic.title;
                                    currentSelectedTopic = topic;
                                  });
                                },
                              );
                            }),

                            // 2. AGREGAR EVALUACIÓN COMO ÚLTIMO ELEMENTO CONSECUTIVO DEL MÓDULO
                            if (moduleQuestions.isNotEmpty)
                              _buildSubItem(
                                // Toma el total de temas válidos y le suma 1 para el consecutivo (ej: 1.5)
                                "${module.order}.${validTopics.length + 1}",
                                "Evaluación",
                                Icons.quiz,
                                isQuiz: true,
                                onTap: () {
                                  setState(() {
                                    _isCreatingNewTopic = false;
                                    selectedItemId =
                                        "${module.order}.${validTopics.length + 1}";
                                    selectedItemType = "quiz";
                                    selectedItemTitle =
                                        "Evaluación del Módulo: ${module.title}";
                                    activeQuizQuestions =
                                        List<QuestionModel>.from(
                                          moduleQuestions,
                                        );
                                  });
                                },
                              ),

                            _buildSubItem(
                              "",
                              "Agregar Tema",
                              Icons.add,
                              isQuiz: false,
                              onTap: () {
                                setState(() {
                                  _isCreatingNewTopic = true;
                                  _activeModuleIdForceCreation = module.order
                                      .toString();
                                  selectedItemId = "";
                                  selectedItemTitle = "Nuevo Title";
                                  selectedItemType = "topic";
                                  currentSelectedTopic = null;
                                });
                              },
                            ),
                            if (moduleQuestions.isEmpty)
                              _buildSubItem(
                                "",
                                "Agregar Evaluación",
                                Icons.add,
                                onTap: () {},
                              ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ),
          const VerticalDivider(width: 1),
          // PANEL DERECHO: Editor de detalles (Aquí se edita el texto/video/quiz seleccionado)
          Expanded(flex: 3, child: Center(child: _buildRightPanelContent())),
        ],
      ),
    );
  }

  Widget _buildSubItem(
    String id,
    String title,
    IconData icon, {
    bool isQuiz = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: false,
      contentPadding: const EdgeInsets.only(left: 40),
      leading: Icon(
        icon,
        size: 20,
        color: isQuiz ? Colors.orange : Colors.grey,
      ),
      title: Text("$id $title"),
      trailing: const Padding(
        padding: EdgeInsetsGeometry.only(right: 30.0),
        child: Icon(Icons.edit, size: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Este curso no tiene módulos aún."),
          TextButton(
            onPressed: () => _addNewModule(context),
            child: const Text("Crear el primer módulo"),
          ),
        ],
      ),
    );
  }

  void _addNewModule(BuildContext context) {
    // Lógica para disparar un diálogo de creación de módulo
  }
  void _showAddContentOptions(String moduleId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text("Texto / Lectura"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text("Video (URL)"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text("Quiz Interactivo"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanelContent() {
    if (selectedItemId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 40, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Editor de Texto / Lectura",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Aquí podrás editar el contenido textual del tema seleccionado.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      // Mostrar editor de texto/video dependiendo del tipo de contenido
    }
    switch (selectedItemType) {
      case "topic":
        return _buildTopicEditor();
      case "quiz":
        return _buildQuizEditor();
      default:
        return const Center(
          child: Text("Selecciona un tema o quiz para editar"),
        );
    }
  }

  Widget _buildTopicEditor() {
    final topic = currentSelectedTopic ?? '';
    if (_isSaving) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Guardando cambios..."),
          ],
        ),
      );
    }
    final String titleValue = _isCreatingNewTopic
        ? ""
        : (currentSelectedTopic?.title ?? '');
    final String contentValue = _isCreatingNewTopic
        ? ""
        : (currentSelectedTopic?.content ?? "");
    final int orderValue = _isCreatingNewTopic
        ? 0
        : (int.tryParse(currentSelectedTopic?.order.toString() ?? '0') ?? 0);
    return TopicEditWidget(
      title: titleValue,
      content: contentValue,
      order: orderValue,
      onSave: (title, content) => {
        if (_isCreatingNewTopic)
          {_createNewTopic(title, content)}
        else
          _updateTopic(title, content),
      },
    );
  }

  Future<void> _createNewTopic(String title, String content) async {
    if (_activeModuleIdForceCreation == null) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final List<ModuleModel> modules = List<ModuleModel>.from(
        widget.course.module,
      );
      for (var moduleMap in modules) {
        if (moduleMap.order.toString() == _activeModuleIdForceCreation) {
          final List<TopicModel> topicList = List.from(moduleMap.topics);
          int nextOrder = topicList.length + 1;
          final TopicModel newTopicMap = TopicModel(
            title: title,
            content: content,
            order: nextOrder,
            hasTopics: false,
            topics: [],
          );
          topicList.add(newTopicMap);
          break;
        }
      }
      await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.course.id.toString())
          .update({'module': modules});
      _reloadCourseFromFirestore();
      setState(() {
        _isSaving = false;
        _isCreatingNewTopic = false;
        _activeModuleIdForceCreation = null;
        selectedItemId = null; // Regresa el panel derecho a su estado inicial
        selectedItemTitle = null;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ ¡Nuevo tema agregado con éxito!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error al crear el tema: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// function buildQuizEditor
  ///
  Widget _buildQuizEditor() {
    return QuestionEditWidget(
      questions: activeQuizQuestions,
      onSave: (update) {},
    );
  }

  ///
  /// method update a Topic in the sources
  Future<void> _updateTopic(String newTitle, String newContent) async {
    if (selectedItemId == null || currentSelectedTopic == null) return;
    List<String> parts = selectedItemId!.split(".");
    String moduleOrder = parts[0];
    String topicOrder = parts.length > 1 ? parts[1] : "";

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Crear una copia de los módulos actuales del curso para modificar localmente
      List<ModuleModel> modules = List<ModuleModel>.from(widget.course.module);
      bool moduleFound = false;

      for (int i = 0; i < modules.length; i++) {
        if (modules[i].order.toString() == moduleOrder) {
          final topics = List<TopicModel>.from(modules[i].topics);
          bool topicFound = false;

          for (int j = 0; j < topics.length; j++) {
            if (topics[j].order.toString() == topicOrder ||
                topics[j].title == currentSelectedTopic.title) {
              topics[j] = topics[j].copyWith(
                title: newTitle,
                content: newContent,
              );
              topicFound = true;
              break;
            }
          }

          if (topicFound) {
            modules[i] = modules[i].copyWith(topics: topics);
            moduleFound = true;
          }
          break;
        }
      }

      if (!moduleFound) {
        throw Exception("No se encontró el módulo o tema para actualizar");
      }

      // 2. Convertir los módulos actualizados a JSON
      List<Map<String, dynamic>> modulesJson = modules
          .map((m) => m.toJson())
          .toList();

      // 3. Actualizar en Firestore
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .update({'module': modulesJson});
      _reloadCourseFromFirestore();
      // 4. Actualizar el estado local
      if (mounted) {
        setState(() {
          if (currentSelectedTopic is TopicModel) {
            currentSelectedTopic = (currentSelectedTopic as TopicModel)
                .copyWith(title: newTitle, content: newContent);
          }
          selectedItemTitle = newTitle;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Contenido actualizado con éxito en Firestore"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error al guardar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateQuiz(List<QuestionModel> updateQuestions) async {
    if (selectedItemId == null) return;
    List<String> parts = selectedItemId!.split('.');
    String moduleOrder = parts[0];
    setState(() {
      _isSaving = true;
    });
    try {
      List<ModuleModel> modules = List<ModuleModel>.from(_localCourse.module);
      bool moduleFound = false;
      for (int i = 0; i < modules.length; i++) {
        if (modules[i].order.toString() == moduleOrder) {
          modules[i] = modules[i].copyWith(questions: updateQuestions);
          moduleFound = true;
          break;
        }
      }
      if (!moduleFound) {
        throw Exception(
          "No se pudo encontrar el modulo asociado a este evaluación",
        );
      }
      List<Map<String, dynamic>> modulesJson = modules.map((module) {
        return {
          'order': module.order,
          'title': module.title,
          'description': module.description,
          'topics': module.topics
              .map(
                (topic) => {
                  'order': topic.order,
                  'title': topic.title,
                  'hasTopics': topic.hasTopics,
                  'content': topic.content,
                },
              )
              .toList(),
          // Mapeamos los reactivos del Quiz con su respectivo 'correctIndex' numérico
          'questions': module.questions!
              .map(
                (q) => {
                  'id': q.id as String,
                  'questionText': q.questionText,
                  'options':
                      q.options, // Es la lista List<String> de alternativas
                  'correctIndex':
                      q.correctIndex, // El entero de la respuesta correcta
                },
              )
              .toList(),
        };
      }).toList();
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(_localCourse.id.toString())
          .update({'module': modulesJson});
      await _reloadCourseFromFirestore();
      if (mounted) {
        setState(() {
          // Sincronizamos la variable de estado local con los datos guardados
          activeQuizQuestions = updateQuestions;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Evaluación actualizada y sincronizada con éxito"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error al persistir la evaluación: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Método estratégico para recargar el curso completo desde Firestore
  Future<void> _reloadCourseFromFirestore() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(_localCourse.id.toString())
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final Map<String, dynamic> courseData = docSnapshot.data()!;
        setState(() {
          // Hidratamos el modelo local mapeando los datos frescos de la BD
          _localCourse = CourseModel.fromFirestore(courseData, docSnapshot.id);
        });
      }
    } catch (e) {
      debugPrint("ERROR al recargar el curso: $e");
    }
  }
}
