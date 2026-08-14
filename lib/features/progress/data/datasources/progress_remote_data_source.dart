import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';

abstract class ProgressRemoteDataSource {
  Future<UserProgressModel> getUserProgress(String userId);
  Future<void> saveUserProgress(UserProgressModel progress);
  Future<void> createUserProgressIfNotExists(String userId);
   FirebaseFirestore get firestore;
}

class ProgressRemoteDataSourceImp implements ProgressRemoteDataSource {
  final FirebaseFirestore _firestore;

  @override 
  FirebaseFirestore get firestore => _firestore;
  ProgressRemoteDataSourceImp(this._firestore);

  @override
  Future<UserProgressModel> getUserProgress(String userId) async {
    final doc = await _firestore.collection('user_progress').doc(userId).get();

    if (!doc.exists) {
      final newProgress = UserProgressModel(
        userId: userId,
        totalXP: 0,
        currentLevel: 1,
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: DateTime.now(),
        courses: [],
      );
      await saveUserProgress(newProgress);
      return newProgress;
    }

    return UserProgressModel.fromFirestore(doc);
  }

  @override
  Future<void> saveUserProgress(UserProgressModel progress) async {
    await _firestore
        .collection('user_progress')
        .doc(progress.userId)
        .set(progress.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> createUserProgressIfNotExists(String userId) async {
    final doc = await _firestore.collection('user_progress').doc(userId).get();
    if (!doc.exists) {
      final newProgress = UserProgressModel(
        userId: userId,
        totalXP: 0,
        currentLevel: 1,
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: DateTime.now(),
        courses: [],
      );
      await saveUserProgress(newProgress);
    }
  }
}
