import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/progress/domain/entities/user_progress.dart';
import 'package:fiuuassistant/features/progress/domain/entities/leve.dart';
import 'xp_bar.dart';
import 'level_badge.dart';
import 'streak_indicator.dart';

class ProgressCard extends StatelessWidget {
  final UserProgress progress;

  const ProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final level = Level.getLevelFromXP(progress.totalXP);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0F2F1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LevelBadge(level: level),
              Text(
                '${(progress.progressToNextLevel * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58A6A6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            level.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6A6A),
            ),
          ),
          Text(
            level.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          XPBar(
            currentXP: progress.totalXP,
            xpForNextLevel: progress.xpForNextLevel,
            progress: progress.progressToNextLevel,
          ),
          const SizedBox(height: 12),
          StreakIndicator(
            currentStreak: progress.currentStreak,
            longestStreak: progress.longestStreak,
          ),
        ],
      ),
    );
  }
}