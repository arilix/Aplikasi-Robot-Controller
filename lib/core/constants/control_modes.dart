enum ControlMode {
  normal,
  pro;

  String get displayName {
    switch (this) {
      case ControlMode.normal:
        return 'Normal Mode';
      case ControlMode.pro:
        return 'Pro Mode';
    }
  }

  String get emoji {
    switch (this) {
      case ControlMode.normal:
        return '⚡';
      case ControlMode.pro:
        return '🎯';
    }
  }
}
