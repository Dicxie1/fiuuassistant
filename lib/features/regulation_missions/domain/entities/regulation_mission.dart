enum MissionCategory {
  matutino,
  estudio,
  social,
  emocional,
  fisica,
  mindfulness,
}

class RegulationMission {
  final String id;
  final String title;
  final String description;
  final MissionCategory category;
  final int xpReward;
  final String scientificBenefit;
  final String iconName;
  final String actionTip;

  const RegulationMission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.xpReward,
    required this.scientificBenefit,
    required this.iconName,
    required this.actionTip,
  });
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'title': title,
      'description': description,
      'category': category.name,
      'xpReward': xpReward,
      'scientificBenefit': scientificBenefit,
      'iconName': iconName,
      'actionTip': actionTip,
    };
  }

  factory RegulationMission.fromJson(Map<String, dynamic> json) {
    return RegulationMission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: MissionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MissionCategory.mindfulness,
      ),
      xpReward: json['xpReward'],
      scientificBenefit: json['scientificBenefit'],
      iconName: json['iconName'],
      actionTip: json['actionTip'],
    );
  }
}
