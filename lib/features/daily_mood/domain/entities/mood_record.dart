class MoodRecord {
  final String id;
  final String userId;
  final String emotion;
  final int intensity;
  final String note;
  final DateTime createdAt;
  MoodRecord({
    required this.id,
    required this.userId,
    required this.emotion,
    required this.intensity,
    required this.note,
    required this.createdAt,
  });
}
