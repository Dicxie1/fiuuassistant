import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakIndicator({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
        const SizedBox(width: 6),
        Text(
          '$currentStreak días',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        if (currentStreak < longestStreak && longestStreak > 0)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Récord: $longestStreak',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}