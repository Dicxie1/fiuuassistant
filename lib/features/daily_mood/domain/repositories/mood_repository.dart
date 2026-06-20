import '../entities/mood_record.dart';

abstract class MoodRepository {
  Future<void> saveMood(MoodRecord mood);
  Stream<List<MoodRecord>> getMoodHistory(String userId);
}
