import 'package:fiuuassistant/features/regulation_missions/domain/entities/regulation_mission.dart';

class RegulationMissionsBank {
  static const List<RegulationMission> allMission = [
    RegulationMission(
      id: "m_ground_tactile",
      title: 'Mission Matutina: Grounding Táctil',
      description:
          'Durante tu desayono, tomáte un minuto para nombrar 3 texturas diferentes que sientas con tus dedos.',
      category: MissionCategory.matutino,
      xpReward: 30,
      scientificBenefit: 'Grounding táctil & presencial mental',
      iconName: 'coffe',
      actionTip:
          'Ejemplo: la calidez de la taza, la suavidad de la mesa o la textura de tu ropa.',
    ),
    RegulationMission(
      id: 'm_study_active',
      title: 'Mission de estudio: Recarga Motora',
      description:
          'Cada 25 min de estudio, levantate y haz 10 sentadillas mientras repites en voz alta un concepto clave',
      category: MissionCategory.estudio,
      xpReward: 35,
      scientificBenefit: 'Activación motora y consolidacion de memoria ',
      iconName: 'fitness_center',
      actionTip:
          'El movimiento activa la circulacion celebral y la retención cognitiva',
    ),
    RegulationMission(
      id: 'm_social_oxytocin',
      title: 'Missión Social: Dosis de Oxitocina',
      description:
          'Envia un audio de 10 segundo a un compañero o amigo diciendo una cualidad que admiras de él o ella.',
      category: MissionCategory.social,
      xpReward: 40,
      scientificBenefit: 'Liberación de oxytocina y vinculo social',
      iconName: 'volunteer_activism',
      actionTip:
          'Expresa aprecion genuino reduce tus niveles de cortisol y mejora el estado de animo.',
    ),
    RegulationMission(
      id: 'm_breath_vagal',
      title: 'Misión de Regulación Vagal',
      description:
          'Realiza 4 ciclos de respiración 4-7-8 (inhalo en 4s, sostengo en 7s, exhalo suavemente en 8s).',
      category: MissionCategory.emocional,
      xpReward: 30,
      scientificBenefit: 'Activación del sistema nervioso parasimpático',
      iconName: 'air',
      actionTip:
          'Concéntrate en hacer la exhalación más larga que la inhalación.',
    ),
    RegulationMission(
      id: 'm_mindful_horizon',
      title: 'Misión del Horizonte',
      description:
          'Sal a la ventana o balcón y enfoca tu mirada en un punto lejano por 60 segundos sin mirar pantallas.',
      category: MissionCategory.mindfulness,
      xpReward: 25,
      scientificBenefit: 'Descanso de la fatiga ocular y cognitiva',
      iconName: 'visibility',
      actionTip:
          'Permite que tus ojos se relajen sin buscar ningún detalle específico.',
    ),
    RegulationMission(
      id: 'm_power_pose',
      title: 'Misión Postura de Poder',
      description:
          'Ponte de pie con la espalda erguida, manos en la cintura y respira profundo durante 2 minutos.',
      category: MissionCategory.fisica,
      xpReward: 30,
      scientificBenefit: 'Reducción de cortisol y aumento de confianza',
      iconName: 'accessibility_new',
      actionTip: 'Siente la estabilidad de tus pies en el suelo.',
    ),
  ];
}
