class TuningModel {
  final int pwmMax;
  final int frequency;
  final int speedNormal;
  final int speedFast;
  final int failsafeTimeout;
  final int joystickDeadZone;
  final int joystickSensitivity;

  const TuningModel({
    required this.pwmMax,
    required this.frequency,
    required this.speedNormal,
    required this.speedFast,
    required this.failsafeTimeout,
    required this.joystickDeadZone,
    required this.joystickSensitivity,
  });

  // ========== DEFAULT SETTINGS ==========
  factory TuningModel.defaultSettings() {
    return const TuningModel(
      pwmMax: 255,
      frequency: 30000,
      speedNormal: 90,
      speedFast: 255,
      failsafeTimeout: 2000,
      joystickDeadZone: 10,
      joystickSensitivity: 70,
    );
  }

  // ========== PRESETS ==========
  factory TuningModel.arenaKasarPreset() {
    return const TuningModel(
      pwmMax: 255,
      frequency: 30000,
      speedNormal: 120,
      speedFast: 255,
      failsafeTimeout: 2000,
      joystickDeadZone: 15,
      joystickSensitivity: 80,
    );
  }

  factory TuningModel.arenaHalusPreset() {
    return const TuningModel(
      pwmMax: 255,
      frequency: 30000,
      speedNormal: 70,
      speedFast: 200,
      failsafeTimeout: 2000,
      joystickDeadZone: 5,
      joystickSensitivity: 60,
    );
  }

  factory TuningModel.turboPreset() {
    return const TuningModel(
      pwmMax: 255,
      frequency: 40000,
      speedNormal: 150,
      speedFast: 255,
      failsafeTimeout: 1500,
      joystickDeadZone: 5,
      joystickSensitivity: 90,
    );
  }

  factory TuningModel.batterySaverPreset() {
    return const TuningModel(
      pwmMax: 180,
      frequency: 20000,
      speedNormal: 60,
      speedFast: 120,
      failsafeTimeout: 3000,
      joystickDeadZone: 15,
      joystickSensitivity: 50,
    );
  }

  // ========== COPY WITH ==========
  TuningModel copyWith({
    int? pwmMax,
    int? frequency,
    int? speedNormal,
    int? speedFast,
    int? failsafeTimeout,
    int? joystickDeadZone,
    int? joystickSensitivity,
  }) {
    return TuningModel(
      pwmMax: pwmMax ?? this.pwmMax,
      frequency: frequency ?? this.frequency,
      speedNormal: speedNormal ?? this.speedNormal,
      speedFast: speedFast ?? this.speedFast,
      failsafeTimeout: failsafeTimeout ?? this.failsafeTimeout,
      joystickDeadZone: joystickDeadZone ?? this.joystickDeadZone,
      joystickSensitivity: joystickSensitivity ?? this.joystickSensitivity,
    );
  }

  // ========== TO MAP (FOR SAVING) ==========
  Map<String, dynamic> toMap() {
    return {
      'pwmMax': pwmMax,
      'frequency': frequency,
      'speedNormal': speedNormal,
      'speedFast': speedFast,
      'failsafeTimeout': failsafeTimeout,
      'joystickDeadZone': joystickDeadZone,
      'joystickSensitivity': joystickSensitivity,
    };
  }

  // ========== FROM MAP (FOR LOADING) ==========
  factory TuningModel.fromMap(Map<String, dynamic> map) {
    return TuningModel(
      pwmMax: map['pwmMax'] ?? 255,
      frequency: map['frequency'] ?? 30000,
      speedNormal: map['speedNormal'] ?? 90,
      speedFast: map['speedFast'] ?? 255,
      failsafeTimeout: map['failsafeTimeout'] ?? 2000,
      joystickDeadZone: map['joystickDeadZone'] ?? 10,
      joystickSensitivity: map['joystickSensitivity'] ?? 70,
    );
  }
}
