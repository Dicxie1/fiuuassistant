import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/mood_record.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_record_model.dart';

class MoodRecoerdImp implements MoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<void> saveMood(MoodRecord mood) async{
    final model = MoodRecordModel(
      id: mood.id,
      userId: mood.userId,
      emotion: mood.emotion,
      intensity: mood.intensity,
      note: mood.note,
      createdAt: mood.createdAt,
    );
    await _firestore.collection('moods').add(model.toMap());
  }
  @override
  Stream<List<MoodRecord>> getMoodHistory(String userId) {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MoodRecordModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
