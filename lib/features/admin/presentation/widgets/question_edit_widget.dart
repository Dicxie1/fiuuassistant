import 'package:fiuuassistant/features/courses_screen/data/models/question_model.dart';
import 'package:flutter/material.dart';

class QuestionEditWidget extends StatefulWidget {
  final List<QuestionModel> questions;
  final Future<void> Function(List<QuestionModel> updatedQuestions) onSave;
  final VoidCallback? onCancel;
  const QuestionEditWidget({
    super.key,
    required this.questions,
    required this.onSave,
    this.onCancel,
  });
  @override
  State<QuestionEditWidget> createState() => _QuestionEditWidget();
}

class _QuestionEditWidget extends State<QuestionEditWidget> {
  bool _isEditQuestion = false;
  late List<QuestionModel> _localQuestions;
  final FocusNode _newQuestionFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
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

  @override
  void dispose() {
    _newQuestionFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewQuestion() {
    if (!_isEditQuestion) {
      setState(() {
        _isEditQuestion = true;
        _localQuestions.add(
          QuestionModel(
            questionText: '',
            options: ['', '', '', ''],
            correctIndex: -1,
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
        _newQuestionFocusNode.requestFocus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Estas editando"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
                Expanded(child: Text("")),
                if (widget.onCancel != null)
                  TextButton.icon(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                  ),

                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await widget.onSave(_localQuestions);
                    if (mounted) {
                      setState(() {
                        _isEditQuestion = false;
                      });
                    }
                  },
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
                    controller: _scrollController,
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
                icon: const Icon(Icons.add, color: Colors.white),
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
    final isLastItem = index == _localQuestions.length + 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: isLastItem && _isEditQuestion
            ? const BorderSide(color: Color(0XFF1A237E), width: 1.5)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  onPressed: () {
                    //remover current elemento
                    setState(() {
                      _localQuestions.removeAt(index);
                      _isEditQuestion = false;
                    });
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: questionItem.questionText,
              focusNode: (isLastItem && _isEditQuestion)
                  ? _newQuestionFocusNode
                  : null,
              decoration: const InputDecoration(
                labelText: "Enunciado de la Pregunta",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {
                  _localQuestions[index] = questionItem.copyWith(question: val);
                });
              },
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
                        Radio<int>(
                          value: optionIndex,
                          groupValue: questionItem.correctIndex >= 0
                              ? questionItem.correctIndex
                              : null,
                          onChanged: (int? selectdIndex) {
                            if (selectdIndex != null) {
                              setState(() {
                                _localQuestions[index] = questionItem.copyWith(
                                  correctIndex: selectdIndex,
                                );
                              });
                            }
                          },
                        ),
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
                                final newOptions = List<String>.from(
                                  questionItem.options,
                                );
                                newOptions[optionIndex] = val;
                                _localQuestions[index] = questionItem.copyWith(
                                  options: newOptions,
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
