class Level {
  final int number;
  final String name;
  final String description;
  final int xpRequired;
  final String? badgeIcon;
  Level({
    required this.number,
    required this.name,
    required this.description,
    required this.xpRequired,
    this.badgeIcon,
  });
  static List<Level> get predefinedLevels =>[
    Level(
      number: 1,
      name: "Principiante",
      description: "Primeros pasos en el aprendizaje",
      xpRequired: 500,
      badgeIcon: "🌱",
    ),
    Level(
      number:2,
      name: "Aprendiz",
      description: "Ganando confianza",
      xpRequired: 1500,
      badgeIcon: "📘",
    ),
    Level(
      number: 3,
      name: "Intermedio",
      description: "Dominando conceptos",
      xpRequired: 3000,
      badgeIcon: "🎯",
    ),
    Level(
      number: 4,
      name: "Avanzado",
      description: "Perfeccionando habilidades",
      xpRequired: 6000,
      badgeIcon: "💪",
    ),
    Level(
      number: 5,
      name: "Experto",
      description: "Maestría en el tema",
      xpRequired: 10000,
      badgeIcon: "🏆",
    ),
  ];
  static Level getLevelFromXP(int xp){
    for (int i = predefinedLevels.length - 1; i >= 0; i--){
      if(xp >= predefinedLevels[i].xpRequired){
        return predefinedLevels[i];
      }
    }
    return predefinedLevels.first;
  }
}
