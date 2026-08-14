import 'package:flutter/material.dart';
import '../../domain/entities/leve.dart';

class LevelBadge extends StatelessWidget {
  final Level level;
  final bool showName;

  const LevelBadge({
    super.key,
    required this.level,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF58A6A6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level.badgeIcon ?? '🏆',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          if (showName)
            Text(
              'Nivel ${level.number}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}