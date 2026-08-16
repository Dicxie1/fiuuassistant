import 'package:flutter/material.dart';
import '../../domain/entities/regulation_mission.dart';
import '../../domain/entities/user_daily_missions.dart';

class RegulationMissionsCard extends StatelessWidget {
  final UserDailyMissions dailyMissions;
  final Function(String missionId) onCompletedMission;
  const RegulationMissionsCard({
    super.key,
    required this.dailyMissions,
    required this.onCompletedMission,
  });
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'coffe':
        return Icons.coffee_outlined;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'volunteer_activism':
        return Icons.volunteer_activism_outlined;
      case 'air':
        return Icons.air_outlined;
      case 'visibility':
        return Icons.visibility_off_outlined;
      default:
        return Icons.auto_awesome;
    }
  }

  Color _getCategoryColor(MissionCategory category) {
    switch (category) {
      case MissionCategory.matutino:
        return const Color(0xFFFF9800);
      case MissionCategory.estudio:
        return const Color(0xFF2196F3);
      case MissionCategory.social:
        return const Color(0xFFE91E63);
      case MissionCategory.emocional:
        return const Color(0xFF9C27B0);
      case MissionCategory.fisica:
        return const Color(0xFF4CAF50);
      case MissionCategory.mindfulness:
        return const Color(0xFF00BCD4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = dailyMissions.items.length;
    final completedCount = dailyMissions.completedCount;
    final progressRatio =
        dailyMissions.completedCount / dailyMissions.items.length;
    final pedingItems = dailyMissions.items
        .where((item) => !item.isCompleted)
        .toList();
    final bool allDone = dailyMissions.isAllCompleted || pedingItems.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18, top: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF355454),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 4),
                  const Text(
                    "Mission de Regulación",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  allDone ? '¡Listo!' : '$completedCount / $totalCount Lista',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF58A6A6),
              ),
            ),
          ),
          const SizedBox(height: 5),
          AnimatedSwitcher(
            duration: const Duration(microseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: allDone
                ? _buildAllCompletedView(context)
                : _buildMissionStack(context, pedingItems),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, RegulationMission mission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        title: const Row(children: [Text('🎉'), Text('!Misión Cumplida¡')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has Completado "${mission.title}".',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'Recompensa: +${mission.xpReward} XP sumando a tu progreso general',
              style: const TextStyle(color: Color(0xFF4A6A6A)),
            ),
            const SizedBox(height: 8),
            Text(
              '💡 Tip: ${mission.actionTip}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58A6A6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('¡Excelente!'),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionStrack(
    BuildContext context,
    List<DailyMissionItem> pendingList,
  ) {
    final currentItem = pendingList.first;
    final mission = currentItem.mission;
    final catColor = _getCategoryColor(mission.category);
    return SizedBox(
      key: ValueKey(mission.id),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          if (pendingList.length >= 3)
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          if (pendingList.length >= 2)
            Positioned(
              top: 7,
              left: 8,
              right: 8,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: catColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: catColor.withValues(alpha: 0.15),
                      child: Icon(
                        _getIconData(mission.iconName),
                        color: catColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mission.category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: catColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${mission.xpReward} 🌟',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xfff57f17),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  mission.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🧠 ', style: TextStyle(fontSize: 11)),
                    Expanded(
                      child: Text(
                        mission.scientificBenefit,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: catColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onCompletedMission(mission.id);
                      _showCompletionDialog(context, mission);
                    },
                    icon: Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Completar Mission',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58A5A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCompletedView(BuildContext context) {
    return Container(
      key: const ValueKey('all_completed'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF58A6A6).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 2),
          const Text(
            '¡Misiones Completadas!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Has completado todas las misiones de regulación por hoy. ¡Ganaste +${dailyMissions.totalXPEarned} XP!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌅', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Text(
                  'Vuelve mañana para nuevos retos',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionStack(
    BuildContext context,
    List<DailyMissionItem> pendient,
  ) {
    final currentItem = pendient.first;
    final mission = currentItem.mission;
    final catColor = _getCategoryColor(mission.category);
    return SizedBox(
      key: ValueKey(mission.id),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          if (pendient.length >= 3)
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          if (pendient.length >= 2)
            Positioned(
              top: 7,
              left: 8,
              right: 8,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: catColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: catColor.withValues(alpha: 0.15),
                      child: Icon(
                        _getIconData(mission.iconName),
                        color: catColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mission.category.name.toLowerCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: catColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${mission.xpReward} xp 🌟',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  mission.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🧠 ', style: TextStyle(fontSize: 11)),
                    Expanded(
                      child: Text(
                        mission.scientificBenefit,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: catColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onCompletedMission(mission.id);
                      _showCompletionDialog(context, mission);
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Completar Misión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58A6A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
