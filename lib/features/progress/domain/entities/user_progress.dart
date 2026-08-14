import './course_progress.dart';

class UserProgress {
  final String userId;
  final int totalXP;
  final int currentLevel;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final List<CourseProgress> courses;

  UserProgress({
    required this.userId,
    required this.totalXP,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.courses,
  });
  int get xpForNextLevel => currentLevel * 500 + 500;

  double get progressToNextLevel {
    final xpInCurrentLevel = totalXP - (currentLevel * 500);
    final xpNeeded = xpForNextLevel;
    return (xpInCurrentLevel / xpNeeded).clamp(0.0, 1.0);
  }
}
