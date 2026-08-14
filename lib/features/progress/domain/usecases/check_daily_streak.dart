import '../repositories/progress_repository.dart';

class CheckDailyStreak {
  final ProgressRepository _repository;

  CheckDailyStreak(this._repository);

  Future<void> call(String userId) async {
    await _repository.checkDailyStreak(userId);
  }
}
