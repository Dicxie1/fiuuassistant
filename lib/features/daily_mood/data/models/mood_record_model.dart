import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/mood_record.dart';

class MoodRecordModel extends MoodRecord {
  MoodRecordModel({
    required super.id,
    required super.userId,
    required super.emotion,
    required super.intensity,
    required super.note,
    required super.createdAt,
  });
  factory MoodRecordModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MoodRecordModel(
      id: documentId,
      userId: map["userId"],
      emotion: map["emotion"],
      intensity: map["intensity"],
      note: map["note"],
      createdAt: map["createdAt"],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'emotion': emotion,
      'intensity': intensity,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt)
    };
  }
}
