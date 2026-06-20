import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                  : ReorderableListView(
                      onReorder: _reordeModules,
                      children: modulesList.map((module) {
                        // Extraemos temas y preguntas de este módulo específico
                        final List<TopicModel> topicsList = module.topics ?? [];
                        final List<QuestionModel> moduleQuestions =
                            module.questions ?? [];

                        // Filtramos por si vienen temas vacíos en la base de datos como en el ejemplo
                        final List<TopicModel> validTopics = topicsList
                            .where((t) => t.title.toString().isNotEmpty)
                            .toList();

                        return ExpansionTile(
                          key: ValueKey(
                            "module_${module.title}_${module.order}",
                          ),
                          onExpansionChanged: (isExpanded) {
                            setState(() {});
                          },
                          leading: const Icon(
                            Icons.folder,
                            color: Colors.indigo,
                          ),
                          // Muestra: "Módulo Historia de la psicología", "Módulo Emociones y Sentimientos", etc.
                          title: Text(
                            "Módulo ${module.order}  ${module.title}",
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
                              String subOrder = "${tIndex + 1}";

                              return _buildSubItem(
                                "${module.order}.$subOrder", // Genera "1.1", "1.2", etc.
                                topic.title,
                                topic.hasTopics
                                    ? Icons.description
                                    : Icons.edit_document,
                                isQuiz: false,
                                onTap: () {
                                  setState(() {
                                    _isCreatingNewTopic = false;
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
                            if (moduleQuestions.isEmpty &&
                                selectedItemId != "${module.order}.quiz")
                              _buildSubItem(
                                "",
                                "Agregar Evaluación",
                                Icons.add,
                                onTap: () {
                                  setState(() {
                                    _isCreatingNewTopic = false;
                                    selectedItemId = "${module.order}.quiz";
                                    selectedItemType = "quiz";
                                    selectedItemTitle =
                                        "Evaluacion del Modulo : ${module.title}";
                                    activeQuizQuestions = [];
                                  });
                                },
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
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final GlobalKey<FormState> fromKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.folder_open, color: Color(0xFF1A237E)),
              SizedBox(width: 10),
              Text(
                "Crear Nuevo Módulo",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 700,
            child: Form(
              key: fromKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Titulo de Modulo",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "El titulo es Obligatorio";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Descripción de Modulo",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fromKey.currentState?.validate() ?? false) {
                  final String title = titleController.text.trim();
                  final String description = descriptionController.text.trim();

                  Navigator.of(dialogContext).pop();
                  setState(() {
                    _isSaving = true;
                  });
                  try {
                    final List<ModuleModel> currentModules =
                        List<ModuleModel>.from(_localCourse.module);
                    final ModuleModel newModule = ModuleModel(
                      title: title,
                      order: currentModules.length + 1,
                      description: description,
                      topics: [],
                      questions: [],
                    );
                    currentModules.add(newModule);
                    final List<Map<String, dynamic>> modulesJson =
                        currentModules.map((m) => m.toJson()).toList();
                    await FirebaseFirestore.instance
                        .collection("courses")
                        .doc(_localCourse.id.toString())
                        .update({"module": modulesJson});
                    await _reloadCourseFromFirestore();
                    if (mounted) {
                      setState(() {
                        _isSaving = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nuevo Módulo creado con exito!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _isSaving = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error al crear el modulo"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reordeModules(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      _isSaving = true;
    });
    try {
      final List<ModuleModel> modules = List<ModuleModel>.from(
        _localCourse.module,
      );
      final ModuleModel moveModule = modules.removeAt(oldIndex);
      modules.insert(newIndex, moveModule);
      for (int i = 0; i < modules.length; i++) {
        modules[i] = modules[i].copyWith(order: i + 1);
      }
      final List<Map<String, dynamic>> modulesJson = modules
          .map((m) => m.toJson())
          .toList();

      await FirebaseFirestore.instance
          .collection("courses")
          .doc(_localCourse.id.toString())
          .update({"module": modulesJson});

      await _reloadCourseFromFirestore();
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Orden del modulo actualizado correctamente"),
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
          const SnackBar(
            content: Text("Error al cambiar el orde del modulo"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final List<String> parts = (selectedItemId ?? "").split(".");
    final int orderValue = _isCreatingNewTopic
        ? 0
        : (parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);
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
      onDelete: _isCreatingNewTopic ? null : _deleteTopic,
    );
  }

  Future<void> _createNewTopic(String title, String content) async {
    if (_activeModuleIdForceCreation == null) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final List<ModuleModel> modules = List<ModuleModel>.from(
        _localCourse.module,
      );
      for (int i = 0; i < modules.length; i++) {
        if (modules[i].order.toString() == _activeModuleIdForceCreation) {
          final List<TopicModel> updatedTopics = List.from(modules[i].topics);
          updatedTopics.add(
            TopicModel(
              title: title,
              content: content,
              order: updatedTopics.length + 1,
              hasTopics: false,
              topics: [],
            ),
          );
          modules[i] = modules[i].copyWith(topics: updatedTopics);
          break;
        }
      }
      List<Map<String, dynamic>> modulesJson = modules
          .map((m) => m.toJson())
          .toList();
      await FirebaseFirestore.instance
          .collection("courses")
          .doc(_localCourse.id.toString())
          .update({'module': modulesJson});
      await _reloadCourseFromFirestore();
      setState(() {
        _isSaving = false;
        _isCreatingNewTopic = false;
        _activeModuleIdForceCreation = null;
        selectedItemId = null; // Regresa el panel derecho a su estado inicial
        selectedItemTitle = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ ¡Nuevo tema agregado con éxito!"),
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
            content: Text("❌ Error al crear el tema: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// function buildQuizEditor
  Widget _buildQuizEditor() {
    return QuestionEditWidget(
      questions: activeQuizQuestions,
      onSave: (updateQuestion) => _updateQuiz(updateQuestion),
      onCancel: () {
        setState(() {
          selectedItemId = null;
          selectedItemType = null;
        });
      },
    );
  }

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
      List<ModuleModel> modules = List<ModuleModel>.from(_localCourse.module);
      bool moduleFound = false;

      for (int i = 0; i < modules.length; i++) {
        if (modules[i].order.toString() == moduleOrder) {
          final topics = List<TopicModel>.from(modules[i].topics);
          bool topicFound = false;

          for (int j = 0; j < topics.length; j++) {
            if ((j + 1).toString() == topicOrder ||
                topics[j].title == currentSelectedTopic.title) {
              topics[j] = topics[j].copyWith(
                title: newTitle,
                content: newContent,
                order: j + 1,
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
          .doc(_localCourse.id.toString())
          .update({'module': modulesJson});
      await _reloadCourseFromFirestore();
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

  Future<void> _deleteTopic() async {
    if (selectedItemId == null || currentSelectedTopic == null) return;
    List<String> parts = selectedItemId!.split(".");
    String moduleOrder = parts[0];
    String topicOrder = parts.length > 1 ? parts[1] : "";
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("¿Eliminiar Tema?"),
            content: Text(
              "¿Estás seguro de que desea eliminar el tema?  Esta acción no se puede deshacer",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Eliminar"),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;
    setState(() {
      _isSaving = true;
    });
    try {
      List<ModuleModel> modules = List<ModuleModel>.from(_localCourse.module);
      bool topicDeleted = false;
      for (int i = 0; i < modules.length; i++) {
        if (modules[i].order.toString() == moduleOrder) {
          final topics = List<TopicModel>.from(modules[i].topics);
          int initialLenght = topics.length;
          topics.removeWhere(
            (t) =>
                t.order.toString() == topicOrder ||
                t.title == currentSelectedTopic.title,
          );
          if (topics.length < initialLenght) {
            for (int j = 0; j < topics.length; j++) {
              topics[j] = topics[j].copyWith(order: j + 1);
            }
            modules[i] = modules[i].copyWith(topics: topics);
            topicDeleted = true;
          }
          break;
        }
      }
      if (!topicDeleted) {
        throw Exception("No se encontro el tema para eliminar");
      }
      List<Map<String, dynamic>> modulesJson = modules
          .map((m) => m.toJson())
          .toList();
      await FirebaseFirestore.instance
          .collection("courses")
          .doc(_localCourse.id.toString())
          .update({'module': modulesJson});

      await _reloadCourseFromFirestore();

      if (mounted) {
        setState(() {
          _isSaving = false;
          selectedItemId = null;
          selectedItemTitle = null;
          currentSelectedTopic = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tema eliminado con éxito"),
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
          const SnackBar(
            content: Text("error al eliminiar "),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
