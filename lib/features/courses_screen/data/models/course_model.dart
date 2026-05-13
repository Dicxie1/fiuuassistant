import 'package:fiuuassistant/features/home_screen/domain/entities/course.dart';
import './module_model.dart';

class CourseModel extends Course {
  CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imgUrl,
    required super.rating,
    required super.instructor,
    required super.duration,
    required super.isNew,
    required super.module,
  });
  factory CourseModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CourseModel(
      id: id,
      title: json['title'] as String? ?? 'Sin título',
      description: json['description'] as String? ?? '',
      imgUrl: json['imgUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      instructor: json['instructor'] as String? ?? 'Anónimo',
      duration: json['duration'] as String? ?? 'N/A',
      isNew: json['isNew'] as bool? ?? false,
      module: json['module'] != null
          ? (json['module'] as List)
                .map((m) => ModuleModel.fromMap(m))
                .toList()
                .cast<ModuleModel>()
          : <ModuleModel>[],
    );
  }
  Map<String, dynamic> toFirebastore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imgUrl': imgUrl,
      'rating': rating,
      'instructor': instructor,
      'duration': duration,
      'isNew': isNew,
      'module': module
          .map(
            (module) => {
              'order': module.order,
              'description': module.description,
              'title': module.title,
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
            },
          )
          .toList(),
    };
  }
}
