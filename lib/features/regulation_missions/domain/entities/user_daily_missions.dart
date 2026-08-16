import 'package:fiuuassistant/features/regulation_missions/domain/entities/regulation_mission.dart';

class DailyMissionItem {
  final RegulationMission mission;
  final bool isCompleted;
  final DateTime? completedAt;

  const DailyMissionItem({
    required this.mission,
    this.isCompleted = false,
    this.completedAt,
  });

  DailyMissionItem copyWith({
    required bool? isCompleted,
    DateTime? completedAt,
  }) {
    return DailyMissionItem(
      mission: mission,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'mission': mission.toJson(),
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory DailyMissionItem.fromJson(Map<String, dynamic> json) {
    return DailyMissionItem(
      mission: RegulationMission.fromJson(
        json['mission'] as Map<String, dynamic>,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class UserDailyMissions {
  final String userId;
  final String date;
  final List<DailyMissionItem> items;
  const UserDailyMissions({
    required this.userId,
    required this.date,
    required this.items,
  });
  int get completedCount => items.where((i) => i.isCompleted).length;
  int get totalXPAvailable =>
      items.fold(0, (sum, i) => sum + i.mission.xpReward);
  int get totalXPEarned => items
      .where((i) => i.isCompleted)
      .fold(0, (sum, i) => sum + i.mission.xpReward);
  bool get isAllCompleted => completedCount == items.length && items.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'date': date,
    'items': items.map((i) => i.toJson()).toList(),
  };
  factory UserDailyMissions.fromJson(Map<String, dynamic> json) {
    return UserDailyMissions(
      userId: json['userId'] as String,
      date: json['date'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => DailyMissionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
