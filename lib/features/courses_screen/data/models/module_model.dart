import './Topic_model.dart';
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
      questions: (map['questions'] as List<dynamic>?)
          ?.map((question) => QuestionModel.fromJson(question))
          .toList(),
    );
  }
}
