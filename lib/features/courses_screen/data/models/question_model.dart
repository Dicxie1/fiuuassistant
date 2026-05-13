class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      correctIndex: int.tryParse(json['correctIndex'].toString()) ?? 0,
    );
  }
}
