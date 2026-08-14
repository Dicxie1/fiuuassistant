import 'package:fiuuassistant/features/progress/domain/entities/course_progress.dart';
import 'package:fiuuassistant/features/progress/domain/entities/user_progress.dart';
import 'package:fiuuassistant/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import '../datasources/progress_remote_data_source.dart';
import '../models/user_progress_model.dart';

class ProgressRepositoryImp implements ProgressRepository {
  final ProgressRemoteDataSource _dataSource;
  ProgressRepositoryImp(this._dataSource);
  @override
  Future<UserProgress> getUserProgress(String userId) async {
    final progressModel = await _dataSource.getUserProgress(userId);
    return progressModel.toEntity();
  }

  @override
  Future<void> updateProgress(UserProgress progress) async {
    final progressModel = UserProgressModel(
      userId: progress.userId,
      totalXP: progress.totalXP,
      currentLevel: progress.currentLevel,
      currentStreak: progress.currentStreak,
      longestStreak: progress.longestStreak,
      lastActivityDate: progress.lastActivityDate,
      courses: progress.courses,
    );
    await _dataSource.saveUserProgress(progressModel);
  }

  @override
  Future<UserProgress> addXPForTopic(
    String userId,
    String topicId,
    String courseId,
    int xpAmount,
  ) async {
    final currentXpToEach = xpAmount <= 0 ? 50 : xpAmount;
    final progressModel = await getUserProgress(userId);
    final now = DateTime.now();
    final Map<String, CourseProgress> uniqueCoursesMap = {};
    for (var c in progressModel.courses) {
      uniqueCoursesMap[c.courseId] = c;
    }
    List<CourseProgress> currentCourses = uniqueCoursesMap.values.toList();

    final courseIndex = currentCourses.indexWhere(
      (c) => c.courseId == courseId,
    );

    if (courseIndex >= 0) {
      final course = progressModel.courses[courseIndex];
      if (course.completedTopics.contains(topicId)) {
        debugPrint(
          '⚠️ Topic $topicId ya otorgó XP anteriormente. Retornando estado actual.',
        );
        return progressModel;
      }
    }
    final newTotalXP = progressModel.totalXP + currentXpToEach;
    final newLevel = _calculateLevel(newTotalXP);
    final totalTopics = await _getTotalTopicsFromCourse(courseId);
    List<CourseProgress> updatedCourses = List.from(currentCourses);
    if (courseIndex >= 0) {
      // El curso ya existe: actualizamos solo la posición específica
      final existingCourse = currentCourses[courseIndex];
      final newCompletedTopics = List<String>.from(
        existingCourse.completedTopics,
      )..add(topicId);

      final newProgress = totalTopics > 0
          ? (newCompletedTopics.length / totalTopics).clamp(0.0, 1.0)
          : 0.0;

      updatedCourses[courseIndex] = existingCourse.copyWith(
        completedTopics: newCompletedTopics,
        progress: newProgress,
        lastActivityDate: now,
      );
    } else {
      // El curso es nuevo: agregamos una única instancia
      final initialProgress = totalTopics > 0
          ? (1.0 / totalTopics).clamp(0.0, 1.0)
          : 0.0;

      updatedCourses.add(
        CourseProgress(
          courseId: courseId,
          progress: initialProgress,
          completedTopics: [topicId],
          lastActivityDate: now,
          enrolledAt: now,
        ),
      );
    }

    // Actualizar racha
    final today = DateTime(now.year, now.month, now.day);
    final lastActivityDay = DateTime(
      progressModel.lastActivityDate.year,
      progressModel.lastActivityDate.month,
      progressModel.lastActivityDate.day,
    );
    final daysDiff = today.difference(lastActivityDay).inDays;

    int newStreak;
    if (daysDiff == 1) {
      newStreak = progressModel.currentStreak + 1;
    } else if (daysDiff > 1) {
      newStreak = 1;
    } else {
      newStreak = progressModel.currentStreak == 0
          ? 1
          : progressModel.currentStreak;
    }

    final newLongestStreak = newStreak > progressModel.longestStreak
        ? newStreak
        : progressModel.longestStreak;

    final newProgress = UserProgressModel(
      userId: userId,
      totalXP: newTotalXP,
      currentLevel: newLevel,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: now,
      courses: updatedCourses,
    );

    await updateProgress(newProgress);
    return newProgress;
  }

  @override
  Future<void> markTopicAsCompleted(
    String userId,
    String topicId,
    String courseId,
  ) async {
    final progress = await getUserProgress(userId);
    final courseIndex = progress.courses.indexWhere(
      (c) => c.courseId == courseId,
    );
    if (courseIndex < 0) return;
    final now = DateTime.now();
    if (courseIndex == -1) {
      final newCourses = List<CourseProgress>.from(progress.courses)
        ..add(
          CourseProgress(
            courseId: courseId,
            progress: 0.0,
            completedTopics: [topicId],
            lastActivityDate: now,
            enrolledAt: now,
          ),
        );
      final newProgress = UserProgressModel(
        userId: userId,
        totalXP: progress.totalXP,
        currentLevel: progress.currentLevel,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        lastActivityDate: progress.lastActivityDate,
        courses: newCourses,
      );
      await updateProgress(newProgress);
      return;
    }
    final course = progress.courses[courseIndex];
    if (!course.completedTopics.contains(topicId)) {
      final newCompletedTopics = List<String>.from(course.completedTopics)
        ..add(topicId);
      final newCourses = List<CourseProgress>.from(progress.courses);
      newCourses[courseIndex] = course.copyWith(
        completedTopics: newCompletedTopics,
        lastActivityDate: now,
      );
      final newProgress = UserProgressModel(
        userId: userId,
        totalXP: progress.totalXP,
        currentLevel: progress.currentLevel,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        lastActivityDate: now,
        courses: newCourses,
      );
      await updateProgress(newProgress);
    }
  }

  @override
  Future<void> checkDailyStreak(String userId) async {
    final progress = await getUserProgress(userId);
    final now = DateTime.now();
    final lastActivity = progress.lastActivityDate;
    final today = DateTime(now.year, now.month, now.day);
    final lastActivityDay = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day,
    );
    final daysDiff = today.difference(lastActivityDay).inDays;
    int newStreak;
    int newLongestStreak = progress.longestStreak;
    if (daysDiff == 1) {
      newStreak = progress.currentStreak + 1;
    } else if (daysDiff > 1) {
      newStreak = 1; // Reinicia la racha
    } else {
      newStreak = progress.currentStreak; // No cambia la racha
    }
    if (newStreak > progress.longestStreak) {
      newLongestStreak = newStreak;
    }
    final newProgress = progress.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: now,
    );
    await updateProgress(newProgress);
  }

  int _calculateLevel(int totalXP) {
    int level = 1;
    int xpRequired = 500;
    while (totalXP >= xpRequired * 500 + 500) {
      level++;
      xpRequired = level * 500 + 500;
    }
    return level;
  }

  Future<int> _getTotalTopicsFromCourse(String courseId) async {
    try {
      final courseDoc = await _dataSource.firestore
          .collection('courses')
          .doc(courseId)
          .get();
      if (!courseDoc.exists) {
        debugPrint('⚠️ Course $courseId not found in Firestore');
        return 0;
      }

      final courseData = courseDoc.data()!;
      final modules = courseData['module'] as List<dynamic>? ?? [];
      int total = 0;
      for (final module in modules) {
        final topics = module['topics'] as List<dynamic>;
        for (final topic in topics) {
          total += 1;
          if (topic['hasTopics'] == true) {
            total += _countSubTopics(topic['topics'] as List<dynamic>? ?? []);
          }
        }
      }
      debugPrint('📊 Course $courseId: Total topics = $total');
      return total;
    } catch (e) {
      debugPrint("$e");
      return 0;
    }
  }

  int _countSubTopics(List<dynamic> subTopics) {
    int count = subTopics.length;
    for (final subTopic in subTopics) {
      if (subTopic['hasTopics'] == true) {
        count += _countSubTopics(subTopic['topics'] as List<dynamic>? ?? []);
      }
    }
    return count;
  }
}

extension UserProgressCopy on UserProgress {
  UserProgress copyWith({
    String? userId,
    int? totalXP,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<String>? completedTopics,
    List<String>? completedCourses,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      courses: courses, // Mantener los cursos existentes
    );
  }
}
