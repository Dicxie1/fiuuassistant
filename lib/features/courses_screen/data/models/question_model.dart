class QuestionModel {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  int? id;
  QuestionModel({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionText:
          (json['questionText'] ?? json['questionText'] ?? 'Sin pregunta')
              as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List<dynamic>)
          : [],
      correctIndex: int.tryParse(json['correctIndex'].toString()) ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctIndex': correctIndex.toString(),
    };
  }

  QuestionModel copyWith({
    String? question,
    List<String>? options,
    int? correctIndex,
  }) {
    return QuestionModel(
      questionText: question ?? questionText,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}
