import '../entities/mood_record.dart';
import '../repositories/mood_repository.dart';

class RecordDailyMood {
  final MoodRepository repository;
  RecordDailyMood(this.repository);
  Future<void> execute(MoodRecord mood) async {
    if (mood.emotion.isEmpty) {
      throw Exception("La emocion no puede estar vacía.");
    }
    return await repository.saveMood(mood);
  }
}
