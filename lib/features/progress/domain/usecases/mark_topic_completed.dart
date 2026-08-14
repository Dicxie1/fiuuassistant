import '../repositories/progress_repository.dart';

class MarkTopicCompleted {
  final ProgressRepository _repository;

  MarkTopicCompleted(this._repository);

  Future<void> call({
    required String userId,
    required String topicId,
    required String courseId,
  }) async {
    await _repository.markTopicAsCompleted(userId, topicId, courseId);
  }
}