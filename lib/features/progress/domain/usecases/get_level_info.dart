import '../entities/leve.dart';

class GetLevelInfo {
  Level call(int totalXP) {
    return Level.getLevelFromXP(totalXP);
  }
}