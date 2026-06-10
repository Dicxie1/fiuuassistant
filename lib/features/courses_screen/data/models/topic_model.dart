import 'question_model.dart';

class TopicModel {
  final String content;
  final String title;
  final int order;
  final bool hasTopics;
  final String? parentModuleName;
  final List<TopicModel> topics;
  final List<QuestionModel>? checkpointQuestions;

  TopicModel({
    required this.title,
    required this.order,
    required this.hasTopics,
    required this.topics,
    required this.content,
    this.parentModuleName,
    this.checkpointQuestions,
  });
  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      title: map['title'] as String? ?? 'Sin título',
      order: int.tryParse(map['order'].toString()) ?? 0,
      hasTopics: map['hasTopics'] as bool? ?? false,
      content: map['content'] as String? ?? '',
      topics:
          (map['subtopics'] as List<dynamic>?)
              ?.map((topic) => TopicModel.fromMap(topic))
              .toList() ??
          [],
    );
  }
  TopicModel copyWith({
    String? title,
    String? content,
    int? order,
    bool? hasTopics,
    List<TopicModel>? topics,
    String? parentModuleName,
    List<QuestionModel>? checkpointQuestions,
  }) {
    return TopicModel(
      title: title ?? this.title,
      order: order ?? this.order,
      hasTopics: hasTopics ?? this.hasTopics,
      topics: topics ?? this.topics,
      content: content ?? this.content,
      parentModuleName: parentModuleName ?? this.parentModuleName,
      checkpointQuestions: checkpointQuestions ?? this.checkpointQuestions,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'order': order,
      'hasTopics': hasTopics,
      'content': content,
      'subtopics': topics
          .map(
            (topic) => {
              'title': topic.title,
              'order': topic.order,
              'hasTopics': topic.hasTopics,
              'content': topic.content,
            },
          )
          .toList(),
    };
  }
}
