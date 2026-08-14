import 'package:fiuuassistant/features/courses_screen/data/models/topic_model.dart';
import 'package:fiuuassistant/features/progress/domain/usecases/add_xp.dart';
import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/question_model.dart';
// Agrega estas líneas después de las importaciones existentes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiuuassistant/features/progress/data/repositories/progress_repository_imp.dart';
import 'package:fiuuassistant/features/progress/data/datasources/progress_remote_data_source.dart';
import 'package:fiuuassistant/features/progress/domain/usecases/check_daily_streak.dart';
import 'package:fiuuassistant/features/progress/domain/usecases/mark_topic_completed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseReaderScreen extends StatefulWidget {
  final List<dynamic> topics;
  final int initialIndex;
  final String courseId;
  const CourseReaderScreen({
    super.key,
    required this.topics,
    this.initialIndex = 0,
    required this.courseId,
  });
  @override
  State<CourseReaderScreen> createState() => _CourseReaderScreenState();
}

class _CourseReaderScreenState extends State<CourseReaderScreen> {
  late PageController _pageController;
  late int _currentIndex = 0;
  late ProgressRepositoryImp _progressRepository;
  late AddXP _addXPUseCase;
  late MarkTopicCompleted _markTopicCompletedUseCase;
  final User? _user = FirebaseAuth.instance.currentUser;
  late CheckDailyStreak _checkDailyStreakUseCase;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    final dataSource = ProgressRemoteDataSourceImp(FirebaseFirestore.instance);
    _progressRepository = ProgressRepositoryImp(dataSource);
    _addXPUseCase = AddXP(_progressRepository);
    _checkDailyStreakUseCase = CheckDailyStreak(_progressRepository);
    _markTopicCompletedUseCase = MarkTopicCompleted(_progressRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerTopicRead(_currentIndex);
    });
  }

  TopicModel? _getTopicModel(dynamic item) {
    if (item is TopicModel) return item;
    if (item is Map<String, dynamic>) return TopicModel.fromMap(item);
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _registerTopicRead(int index) async {
    try {
      if (_user != null && index < widget.topics.length) {
        final topic = _getTopicModel(widget.topics[index]);
        if (topic == null) return;

        final topicId = '${widget.courseId}_${topic.title.trim()}';
        final courseId = widget.courseId;

        await _addXPUseCase.call(
          userId: _user.uid,
          topicId: topicId,
          courseId: courseId,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el progreso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTopic = widget.topics[_currentIndex] as TopicModel;
    final progress = (_currentIndex + 1) / widget.topics.length;
    final isLastPage = _currentIndex == widget.topics.length - 1;
    final isFirstPage = _currentIndex == 0;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text(currentTopic.parentModuleName ?? 'Tema'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.topics.length,
              onPageChanged: (index) async {
                setState(() => _currentIndex = index);
                await _registerTopicRead(index);
              },

              itemBuilder: (context, index) {
                final topic = widget.topics[index] as TopicModel;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0), // Espacio para el botón
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(topic.content, style: const TextStyle(fontSize: 16)),
                      if (topic.checkpointQuestions != null &&
                          topic.checkpointQuestions!.isNotEmpty) ...[
                        SizedBox(height: 16),
                        const Divider(),
                        Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.quiz,
                                size: 50,
                                color: Colors.orange,
                              ),
                              const Text(
                                "¿Haz comprendido la unidad?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _showCheckPoint(
                                    context,
                                    topic.checkpointQuestions!,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text("Realizar cuestionario"),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: _buildNavigationButtons(isFirstPage, isLastPage),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isFirstPage, bool isLastPage) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isFirstPage)
            OutlinedButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(microseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              label: const Text("Anterior"),
              icon: const Icon(Icons.arrow_back_ios_new),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton.icon(
            onPressed: () async {
              if (isLastPage) {
                if (_user == null) {
                  Navigator.pop(context);
                  return;
                }
                final currentTopic = widget.topics[_currentIndex] as TopicModel;

                final topicId = '${widget.courseId}_${currentTopic.title}';
                final courseId = widget.courseId;
                setState(() => _isLoading = true);

                try {
                  // Agregar XP por completar el tema
                  await _addXPUseCase.call(
                    userId: _user.uid,
                    topicId: topicId, // Usamos el título como ID único
                    courseId: courseId,
                  );
                  // Mostrar notificación de XP ganado
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ +50 XP por completar el tema!'),
                      backgroundColor: Color(0xFF58A6A6),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al registrar progreso: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (context.mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            label: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(isLastPage ? "Finalizar (+50 XP)" : "Siguiente"),
            icon: _isLoading
                ? null
                : Icon(isLastPage ? Icons.check_circle : Icons.arrow_forward),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckPoint(BuildContext context, List<QuestionModel> questions) {
    Map<int, int> userAnswers = {};
    Map<int, bool> validatedQuestion = {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    "🚀 Desafío de Comprensión",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const Text("Demuestra lo aprendido en esta unidad"),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        bool isAnswered = userAnswers[index] != null;
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 20.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pregunta ${index + 1}. ${question.questionText}",
                                  style: const TextStyle(
                                    color: Color.fromRGBO(0, 121, 107, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question.questionText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...List.generate(question.options.length, (
                                  optionIndex,
                                ) {
                                  Color optionColor = Colors.grey.shade200;
                                  Color borderColor = Colors.grey.shade400;
                                  if (userAnswers[index] == optionIndex) {
                                    if (optionIndex == question.correctIndex) {
                                      optionColor = Colors.green.shade100;
                                      borderColor = Colors.green;
                                    } else if (optionIndex ==
                                        userAnswers[index]) {
                                      optionColor = Colors.red.shade100;
                                      borderColor = Colors.red;
                                    }
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      if (!isAnswered) {
                                        setState(() {
                                          userAnswers[index] = optionIndex;
                                          validatedQuestion[index] =
                                              optionIndex ==
                                              question.correctIndex;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: optionColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        question.options[optionIndex],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              userAnswers[index] == optionIndex
                                              ? (optionIndex ==
                                                        question.correctIndex
                                                    ? Colors.green.shade800
                                                    : Colors.red.shade800)
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(vertical: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Cerrar"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
