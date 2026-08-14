import '../entities/user_progress.dart';
import '../repositories/progress_repository.dart';

class GetUserProgress {
  final ProgressRepository _repository;

  GetUserProgress(this._repository);

  Future<UserProgress> call(String userId) async {
    return await _repository.getUserProgress(userId);
  }
}
