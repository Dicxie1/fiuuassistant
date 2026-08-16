import 'package:fiuuassistant/features/progress/data/repositories/progress_repository_imp.dart';
import 'package:fiuuassistant/features/progress/domain/repositories/progress_repository.dart';
import '../../domain/entities/user_daily_missions.dart';
import '../datasources/regulation_missions_remote_data_source.dart';

class RegulationMissionsRepositoryImp {
  final RegulationMissionsRemoteDataSource _dataSource;
  final ProgressRepositoryImp _progressRepositoryImp;
  RegulationMissionsRepositoryImp(
    this._dataSource,
    this._progressRepositoryImp,
  );
  Future<UserDailyMissions> getTodayMissions(String userId) async {
    return await _dataSource.getTodayMission(userId);
  }

  Future<UserDailyMissions> completeMission(
    String userId,
    String missionId,
  ) async {
    final updatedMission = await _dataSource.updateMissionsStatus(
      userId,
      missionId,
      true,
    );
    final completedItem = updatedMission.items.firstWhere(
      (i) => i.mission.id == missionId,
    );
    final xpAwarded = completedItem.mission.xpReward;
    final currentProgress = await _progressRepositoryImp.getUserProgress(
      userId,
    );
    final newXP = currentProgress.totalXP + xpAwarded;
    final updatedProgress = currentProgress.copyWith(
      totalXP: newXP,
      lastActivityDate: DateTime.now(),
    );
    await _progressRepositoryImp.updateProgress(updatedProgress);
    return updatedMission;
  }
}
