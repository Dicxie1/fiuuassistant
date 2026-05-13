import 'package:fiuuassistant/features/courses_screen/data/models/module_model.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/topic_model.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String imgUrl;
  final double rating;
  final String instructor;
  final String duration;
  final bool isNew;
  final List<ModuleModel> module;
  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imgUrl,
    required this.rating,
    required this.instructor,
    required this.duration,
    required this.isNew,
    required this.module,
  });
}

class Module {
  final int order;
  final String description;
  final String title;
  final List<TopicModel> topics;

  Module({
    required this.order,
    required this.description,
    required this.title,
    required this.topics,
  });
}

class Topic {
  final int order;
  final String title;
  final bool hasTopics;
  final List<Topic> topics;
  final String content;

  Topic({
    required this.order,
    required this.title,
    required this.hasTopics,
    required this.topics,
    required this.content,
  });
}
