import 'package:fiuuassistant/features/courses_screen/data/models/question_model.dart';
import 'package:flutter/material.dart';

class QuestionEditWidget extends StatefulWidget {
  final List<QuestionModel> questions;
  final Function(List<QuestionModel> updatedQuestions) onSave;
  const QuestionEditWidget({
    super.key,
    required this.questions,
    required this.onSave,
  });
  @override
  State<QuestionEditWidget> createState() => _QuestionEditWidget();
}

class _QuestionEditWidget extends State<QuestionEditWidget> {
  late List<QuestionModel> _localQuestions;
  @override
  void initState() {
    super.initState();
    _localQuestions = List<QuestionModel>.from(widget.questions);
  }

  @override
  void didUpdateWidget(covariant QuestionEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questions != widget.questions) {
      _localQuestions = List<QuestionModel>.from(widget.questions);
    }
  }

  void _addNewQuestion() {
    setState(() {
      _localQuestions.add(
        QuestionModel(
          questionText: '',
          options: ['', '', '', ''],
          correctIndex: -1,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _localQuestions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.quiz, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Configurar Quiz",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => widget.onSave(_localQuestions),
                  icon: Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _localQuestions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _localQuestions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(index);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            width: double.infinity,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _addNewQuestion,
                label: const Text(
                  "Añadir Pregunta",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            "No hay evaluación.",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final questionItem = _localQuestions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pregunta #${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: questionItem.questionText,
              decoration: const InputDecoration(
                labelText: "Enunciado de la Pregunta",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Opciones de respuesta (Marca el botón de la respuesta correcta):",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: questionItem.correctIndex >= 0
                  ? questionItem.correctIndex
                  : null,
              onChanged: (int? selectedIndex) {
                if (selectedIndex != null) {
                  setState(() {
                    _localQuestions[index] = questionItem.copyWith(
                      correctIndex: selectedIndex,
                    );
                  });
                }
              },
              child: Column(
                children: List.generate(questionItem.options.length, (
                  optionIndex,
                ) {
                  final optionText = questionItem.options[optionIndex];
                  return Padding(
                    key: ValueKey("${index}_option$optionIndex"),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Radio<int>(value: optionIndex),
                        Expanded(
                          child: TextFormField(
                            initialValue: optionText,
                            decoration: InputDecoration(
                              hintText: "Opción ${optionIndex + 1}",
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(10),
                            ),
                            onChanged: (val) {
                              setState(() {
                                questionItem.options[optionIndex] = val;
                                _localQuestions[index] = questionItem.copyWith(
                                  options: questionItem.options,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
