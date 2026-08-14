import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

abstract class EnrollmentRepository {
  Future<List<String>> getEnrollmentCourses(String userId);
  Future<bool> isEnrolled(String userId, String courseId);
  Future<void> enroll(String userId, String courseId);
  Future<void> unenroll(String userId, String courseId);
  Future<void> updateProgress(String userId, String courseid, String topic);
  Future<double> getCourseProgress(String userId, String courseId);
}

class EnrollmentRepositoryImp implements EnrollmentRepository {
  final FirebaseFirestore _firestore;
  EnrollmentRepositoryImp(this._firestore);

  @override
  Future<List<String>> getEnrollmentCourses(String userId) async {
    final doc = await _firestore
        .collection('user_enrollments')
        .doc(userId)
        .get();
    if (!doc.exists) {
      return [];
    }
    final data = doc.data();
    final courses = data?['courses'] as List<dynamic>? ?? [];
    return courses.map((c) => c['courseId'].toString()).toList();
  }

  @override
  Future<bool> isEnrolled(String userId, String courseId) async {
    final enrolledCourses = await getEnrollmentCourses(userId);
    return enrolledCourses.contains(courseId);
  }

  @override
  Future<void> enroll(String userId, String courseId) async {
    final docRef = _firestore.collection('user_enrollments').doc(userId);
    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          transaction.set(docRef, {
            'userId': userId,
            'courses': [
              {
                'courseId': courseId,
                'enrolledAt': Timestamp.now(),
                'progress': 0.0,
                'completedTopics': [],
              },
            ],
            'createdAt': Timestamp.now(),
          });
        } else {
          final data = doc.data();
          final courses = List.from(data?['courses'] ?? []);
          final alreadyEnrolled = courses.any((c) => c['courseId'] == courseId);
          if (!alreadyEnrolled) {
            courses.add({
              'courseId': courseId,
              'enrolledAt': Timestamp.now(),
              'progress': 0.0,
              'completedTopics': [],
            });
            transaction.update(docRef, {'courses': courses});
          }
        }
      });
    } catch (e) {
      debugPrint(
        "Error al matricular al usuario $userId en el curso $courseId: $e",
      );
      rethrow;
    }
  }

  @override
  Future<void> unenroll(String userId, String courseId) async {
    final docRef = _firestore.collection('user_enrollments').doc(userId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data();
      final courses = List.from(data?['courses'] ?? []);
      courses.removeWhere((c) => c['courseId'] == courseId);
      await docRef.update({'courses': courses});
    }
  }

  @override
  Future<void> updateProgress(
    String userId,
    String courseId,
    String topicId,
  ) async {
    final docRef = _firestore.collection('user_enrollments').doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await _createUserProgress(docRef, userId, courseId, topicId);
      return;
    }

    final data = doc.data();
    final courses = List.from(data?['courses'] ?? []);
    final courseIndex = courses.indexWhere((c) => c['courseId'] == courseId);
    if (courseIndex != -1) {
      final courseData = Map<String, dynamic>.from(
        courses[courseIndex] as Map<String, dynamic>,
      );
      final completedTopics = List<String>.from(
        courseData['completedTopics'] ?? [],
      );
      if (!completedTopics.contains(topicId)) {
        completedTopics.add(topicId);
        courseData['completedTopics'] = completedTopics;
        final courseDoc = await _firestore
            .collection('courses')
            .doc(courseId)
            .get();
        if (courseDoc.exists) {
          final courseInfo = courseDoc.data();
          final modules = courseInfo?['module'] as List<dynamic>? ?? [];
          int totalTopics = 0;

          for (final module in modules) {
            totalTopics += (module['topics'] as List<dynamic>? ?? []).length;
          }

          if (totalTopics > 0) {
            courseData['progress'] = completedTopics.length / totalTopics;
          }
        }
        courses[courseIndex] = courseData;
        await docRef.update({'courses': courses});
      }
    } else {
      // curso no existe, lo añade
      await _addCourseToProgress(docRef, userId, courseId, topicId);
    }
  }

  @override
  Future<double> getCourseProgress(String userId, String courseId) async {
    final doc = await _firestore.collection('user_progress').doc(userId).get();
    if (!doc.exists) return 0.0;

    final data = doc.data();
    final courses = List.from(data?['courses'] ?? []);

    final courseData = courses.firstWhere(
      (c) => c['courseId'] == courseId,
      orElse: () => null,
    );
    if (courseData != null && courseData['progress'] != null) {
      return (courseData['progress'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _createUserProgress(
    DocumentReference docRef,
    String userId,
    String courseId,
    String topicId,
  ) async {
    final courseDoc = await _firestore
        .collection('courses')
        .doc(courseId)
        .get();
    int totalTopics = 0;

    if (courseDoc.exists) {
      final courseInfo = courseDoc.data();
      final modules = courseInfo?['module'] as List<dynamic>? ?? [];
      for (final module in modules) {
        totalTopics += (module['topics'] as List<dynamic>? ?? []).length;
      }
    }

    final progress = totalTopics > 0 ? 1 / totalTopics : 0.0;

    await docRef.set({
      'userId': userId,
      'totalXP': 0,
      'currentLevel': 1,
      'currentStreak': 0,
      'longestStreak': 0,
      'lastActivityDate': FieldValue.serverTimestamp(),
      'courses': [
        {
          'courseId': courseId,
          'progress': progress,
          'completedTopics': [topicId],
          'enrolledAt': FieldValue.serverTimestamp(),
        },
      ],
    });
  }

  Future<void> _addCourseToProgress(
    DocumentReference docRef,
    String userId,
    String courseId,
    String topicId,
  ) async {
    final doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>?;
    final courses = List.from(data?['courses'] ?? []);

    final courseDoc = await _firestore
        .collection('courses')
        .doc(courseId)
        .get();
    int totalTopics = 0;

    if (courseDoc.exists) {
      final courseInfo = courseDoc.data();
      final modules = courseInfo?['module'] as List<dynamic>? ?? [];
      for (final module in modules) {
        totalTopics += (module['topics'] as List<dynamic>? ?? []).length;
      }
    }

    final progress = totalTopics > 0 ? 1 / totalTopics : 0.0;

    courses.add({
      'courseId': courseId,
      'progress': progress,
      'completedTopics': [topicId],
      'enrolledAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'courses': courses});
  }
}
