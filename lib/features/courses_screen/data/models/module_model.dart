import './topic_model.dart';
import './question_model.dart';

class ModuleModel {
  final String title;
  final int order;
  final String description;
  final List<TopicModel> topics;
  final List<QuestionModel>? questions;

  ModuleModel({
    required this.title,
    required this.order,
    required this.description,
    required this.topics,
    required this.questions,
  });
  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      title: map['title'] as String? ?? 'Sin título',
      order: int.tryParse(map['order'].toString()) ?? 0,
      description: map['description'] as String? ?? '',
      topics:
          (map['topics'] as List<dynamic>?)
              ?.map(
                (topic) => TopicModel(
                  title: topic['title'] as String? ?? 'Sin título',
                  order: int.tryParse(topic['order'].toString()) ?? 0,
                  hasTopics: topic['hasTopics'] as bool? ?? false,
                  content: topic['content'] as String? ?? '',
                  topics:
                      (map['topics'] as List<dynamic>?)
                          ?.map(
                            (topic) => TopicModel.fromMap(
                              topic as Map<String, dynamic>,
                            ),
                          )
                          .toList() ??
                      [],
                ),
              )
              .toList() ??
          [],
      questions: map['questions'] != null
          ? (map['questions'] as List)
                .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
                .toList()
          : <QuestionModel>[],
    );
  }
  ModuleModel copyWith({
    String? title,
    int? order,
    String? description,
    List<TopicModel>? topics,
    List<QuestionModel>? questions,
  }) {
    return ModuleModel(
      title: title ?? this.title,
      order: order ?? this.order,
      description: description ?? this.description,
      topics: topics ?? this.topics,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'order': order,
    'description': description,
    'topics': topics
        .map(
          (topic) => {
            'title': topic.title,
            'order': topic.order,
            'hasTopics': topic.hasTopics,
            'content': topic.content,
            'subtopics': topic.topics
                .map(
                  (subtopic) => {
                    'title': subtopic.title,
                    'order': subtopic.order,
                    'hasTopics': subtopic.hasTopics,
                    'content': subtopic.content,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'questions': questions
        ?.map(
          (q) => {
            'questionText': q.questionText,
            'options': q.options,
            'correctIndex': q.correctIndex,
          },
        )
        .toList(),
  };
}
