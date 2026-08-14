import '../../domain/entities/leve.dart';

class LevelModel extends Level {
  LevelModel({
    required super.number,
    required super.name,
    required super.description,
    required super.xpRequired,
    required super.badgeIcon,
  });

  factory LevelModel.fromJson(Map<String, dynamic> map) {
    return LevelModel(
      number: map['number'] ?? 1,
      name: map['name'] ?? 'Principiante',
      description: map['description'] ?? '',
      xpRequired: map['xpRequired'] ?? 0,
      badgeIcon: map['badgeIcon'],
    );
  }
  Map<String, dynamic> toJson(){
    return {
      'number': number,
      'name': name,
      'description': description,
      'xpRequired': xpRequired,
      'badgeIcon': badgeIcon,
    };
  }
}
