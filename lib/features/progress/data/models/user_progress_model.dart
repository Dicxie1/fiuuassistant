import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/course_progress.dart';

class UserProgressModel extends UserProgress {
  UserProgressModel({
    required super.userId,
    required super.totalXP,
    required super.currentLevel,
    required super.currentStreak,
    required super.longestStreak,
    required super.lastActivityDate,
    required super.courses,
  });

  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProgressModel(
      userId: doc.id,
      totalXP: data['totalXP'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActivityDate: data['lastActivityDate'] != null
          ? (data['lastActivityDate'] as Timestamp).toDate()
          : DateTime.now(),
     courses: (data['courses'] as List<dynamic>? ?? [])
          .map((courseData) => CourseProgress(
                courseId: courseData['courseId'] ?? '',
                progress: (courseData['progress'] as num?)?.toDouble() ?? 0.0,
                completedTopics: List<String>.from(
                  courseData['completedTopics'] ?? <String>[],
                ),
                lastActivityDate: courseData['lastActivityDate'] != null
                    ? (courseData['lastActivityDate'] as Timestamp).toDate()
                    : DateTime.now(),
                enrolledAt: courseData['enrolledAt'] != null
                    ? (courseData['enrolledAt'] as Timestamp).toDate()
                    : DateTime.now(),// Nested courses are not handled in this example
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': Timestamp.fromDate(lastActivityDate),
      'courses': courses.map((course) {
        return {
          'courseId': course.courseId,
          'progress': course.progress,
          'completedTopics': course.completedTopics,
          'lastActivityDate': Timestamp.fromDate(course.lastActivityDate),
          'enrolledAt': Timestamp.fromDate(course.enrolledAt),
        };
      }).toList(),
    };
  }

  UserProgress toEntity() {
    return UserProgress(
      userId: userId,
      totalXP: totalXP,
      currentLevel: currentLevel,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: lastActivityDate,
      courses: courses,
    );
  }
}
