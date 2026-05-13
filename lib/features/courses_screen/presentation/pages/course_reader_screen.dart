import 'package:fiuuassistant/features/courses_screen/data/models/Topic_model.dart';
import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/question_model.dart';

class CourseReaderScreen extends StatefulWidget {
  final List<dynamic> topics;
  final int initialIndex;
  const CourseReaderScreen({
    super.key,
    required this.topics,
    this.initialIndex = 0,
  });
  @override
  State<CourseReaderScreen> createState() => _CourseReaderScreenState();
}

class _CourseReaderScreenState extends State<CourseReaderScreen> {
  late PageController _pageController;
  late int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },

              itemBuilder: (context, index) {
                final topic = widget.topics[index] as TopicModel;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      20.0,
                    ), // Espacio para el botón
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
                        Text(
                          topic.content,
                          style: const TextStyle(fontSize: 16),
                        ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationButtons(isFirstPage, isLastPage),
    );
  }

  Widget _buildNavigationButtons(bool isFirstPage, bool isLastPage) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
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
            onPressed: () {
              if (isLastPage) {
                Navigator.pop(context);
              } else {
                _pageController.nextPage(
                  duration: const Duration(microseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            label: Text(isLastPage ? "Finalizar" : "Siguiente"),
            icon: Icon(isLastPage ? Icons.check_circle : Icons.arrow_forward),
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
            padding: const EdgeInsets.all(20.0),
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
                      bool isCorrect =
                          userAnswers[index] == question.correctIndex;
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
                                "Pregunta ${index + 1}. ${question.question}",
                                style: const TextStyle(
                                  color: Color.fromRGBO(0, 121, 107, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.question,
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
                                        color: userAnswers[index] == optionIndex
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cerrar"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
