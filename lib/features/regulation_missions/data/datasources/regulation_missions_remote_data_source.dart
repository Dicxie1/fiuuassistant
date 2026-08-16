import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/regulation_mission.dart';
import '../../domain/entities/user_daily_missions.dart';
import 'regulation_missions_bank.dart';

class RegulationMissionsRemoteDataSource {
  final FirebaseFirestore _firestore;
  RegulationMissionsRemoteDataSource(this._firestore);
  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<UserDailyMissions> getTodayMission(String userId) async {
    final today = _getTodayDateString();
    final docId = "${userId}_$today";
    final doc = await _firestore
        .collection('user_regulation_missions')
        .doc(docId)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserDailyMissions.fromJson(doc.data()!);
    }
    final seltectedMission = _generateDailyMissions(today);
    final dailyMissions = UserDailyMissions(
      userId: userId,
      date: today,
      items: seltectedMission.map((m) => DailyMissionItem(mission: m)).toList(),
    );
    await _firestore
        .collection('user_regulation_missions')
        .doc(docId)
        .set(dailyMissions.toJson(), SetOptions(merge: true));
    return dailyMissions;
  }

  List<RegulationMission> _generateDailyMissions(String seedDate) {
    final bank = List<RegulationMission>.from(
      RegulationMissionsBank.allMission,
    );
    final random = Random(seedDate.hashCode);
    bank.shuffle(random);
    return bank.take(3).toList();
  }

  Future<UserDailyMissions> updateMissionsStatus(
    String userId,
    String missionId,
    bool isCompleted,
  ) async {
    final today = _getTodayDateString();
    final docId = "${userId}_$today";
    final current = await getTodayMission(userId);
    final updatedItems = current.items.map((item) {
      if (item.mission.id == missionId) {
        return item.copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }
      return item;
    }).toList();
    final update = UserDailyMissions(
      userId: userId,
      date: today,
      items: updatedItems,
    );
    await _firestore
        .collection('user_regulation_missions')
        .doc(docId)
        .set(update.toJson(), SetOptions(merge: true));
    return update;
  }
}
