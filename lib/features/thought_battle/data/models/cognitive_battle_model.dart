class CognitiveEnemy {
  final String id;
  final String distortedThought;
  final String category;
  final double maxHealth;
  final List<String> presetCounterAttacks;
  CognitiveEnemy({
    required this.id,
    required this.distortedThought,
    required this.category,
    this.maxHealth = 100.0,
    required this.presetCounterAttacks,
  });
}
