import 'package:flutter/material.dart';

class XPBar extends StatelessWidget {
  final int currentXP;
  final int xpForNextLevel;
  final double progress;

  const XPBar({
    super.key,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF58A6A6)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 6),
        Text(
          '$currentXP / $xpForNextLevel XP',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}