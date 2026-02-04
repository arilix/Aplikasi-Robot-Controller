enum RobotType {
  soccer,
  sumo;

  String get displayName {
    switch (this) {
      case RobotType.soccer:
        return 'Soccer Robot';
      case RobotType.sumo:
        return 'Sumo Robot';
    }
  }

  String get emoji {
    switch (this) {
      case RobotType.soccer:
        return '⚽';
      case RobotType.sumo:
        return '🤼';
    }
  }

  String get description {
    switch (this) {
      case RobotType.soccer:
        return 'Speed & Agility';
      case RobotType.sumo:
        return 'Power & Torque';
    }
  }

  String get prefix {
    switch (this) {
      case RobotType.soccer:
        return 'SOCCER-';
      case RobotType.sumo:
        return 'SUMO-';
    }
  }
}
