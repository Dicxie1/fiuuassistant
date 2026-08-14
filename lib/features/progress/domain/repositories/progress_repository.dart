import '../entities/user_progress.dart';
abstract class ProgressRepository {
  Future<UserProgress> getUserProgress(String userId);
  Future<void> updateProgress(UserProgress progress);
  Future<UserProgress> addXPForTopic(
    String userId,
    String topicId,
    String courseId,
    int xpAmount,
  );
  Future<void> markTopicAsCompleted(
    String userId,
    String topicId,
    String courseId,
  );
  Future<void> checkDailyStreak(String userId);
}
