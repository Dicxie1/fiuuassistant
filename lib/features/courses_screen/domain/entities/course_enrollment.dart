
class CourseEnrollment {
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final double progress;
  final List<String> completedTopics;

  CourseEnrollment({
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.progress = 0.0,
    this.completedTopics = const [],
  });
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'enrolledAt': enrolledAt,
      'progress': progress,
      'completedTopics': completedTopics,
    };
  }

  factory CourseEnrollment.fromMap(Map<String, dynamic> map) {
    return CourseEnrollment(
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      enrolledAt: DateTime.parse(
        map['enrolledAt'] ?? DateTime.now().toIso8601String(),
      ),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      completedTopics: List<String>.from(map['completedTopics'] ?? []),
    );
  }
  CourseEnrollment copyWith({
    String? userId,
    String? courseId,
    DateTime? enrolledAt,
    double? progress,
    List<String>? completedTopics,
  }) {
    return CourseEnrollment(
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      progress: progress ?? this.progress,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }

  Future<void> updateStreak(String userId) async {
    
  }
}
