
class CourseProgress {
  // Properties
  final String courseId;
  final double progress;
  final List<String> completedTopics;
  final DateTime lastActivityDate;
  final DateTime enrolledAt;
  // Constructor
  CourseProgress({
    required this.courseId,
    required this.progress,
    required this.completedTopics,
    required this.lastActivityDate,
    required this.enrolledAt,
  });
  // Method to create a copy of the CourseProgress with updated values
  CourseProgress copyWith({
    String? courseId,
    double? progress,
    List<String>? completedTopics,
    DateTime? lastActivityDate,
    DateTime? enrolledAt,
    List<CourseProgress>? courses,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      progress: progress ?? this.progress,
      completedTopics: completedTopics ?? this.completedTopics,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }
}
