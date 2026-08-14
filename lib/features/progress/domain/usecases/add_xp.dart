import '../entities/user_progress.dart';
import '../repositories/progress_repository.dart';

class AddXP {
  final ProgressRepository _repository;

  // XP por completar lectura de tema
  static const int XP_FOR_TOPIC_COMPLETION = 50;

  AddXP(this._repository);

  Future<UserProgress> call({
    required String userId,
    required String topicId,
    required String courseId,
  }) async {
    return await _repository.addXPForTopic(
      userId,
      topicId,
      courseId,
      XP_FOR_TOPIC_COMPLETION,
    );
  }
}