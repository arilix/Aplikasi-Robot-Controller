import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/tuning_model.dart';

class TuningProvider extends ChangeNotifier {
  TuningModel _tuning = TuningModel.defaultSettings();

  // Getters
  TuningModel get tuning => _tuning;
  int get pwmMax => _tuning.pwmMax;
  int get frequency => _tuning.frequency;
  int get speedNormal => _tuning.speedNormal;
  int get speedFast => _tuning.speedFast;
  int get failsafeTimeout => _tuning.failsafeTimeout;
  int get joystickDeadZone => _tuning.joystickDeadZone;
  int get joystickSensitivity => _tuning.joystickSensitivity;

  TuningProvider() {
    _loadTuning();
  }

  // ========== LOAD TUNING ==========
  Future<void> _loadTuning() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      _tuning = TuningModel(
        pwmMax: prefs.getInt('tuning_pwm_max') ?? 255,
        frequency: prefs.getInt('tuning_frequency') ?? 30000,
        speedNormal: prefs.getInt('tuning_speed_normal') ?? 90,
        speedFast: prefs.getInt('tuning_speed_fast') ?? 255,
        failsafeTimeout: prefs.getInt('tuning_failsafe_timeout') ?? 2000,
        joystickDeadZone: prefs.getInt('tuning_joystick_dead_zone') ?? 10,
        joystickSensitivity: prefs.getInt('tuning_joystick_sensitivity') ?? 70,
      );

      notifyListeners();
    } catch (e) {
      print('Load tuning error: $e');
    }
  }

  // ========== UPDATE TUNING ==========
  Future<void> updateTuning(TuningModel newTuning) async {
    _tuning = newTuning;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tuning_pwm_max', newTuning.pwmMax);
      await prefs.setInt('tuning_frequency', newTuning.frequency);
      await prefs.setInt('tuning_speed_normal', newTuning.speedNormal);
      await prefs.setInt('tuning_speed_fast', newTuning.speedFast);
      await prefs.setInt('tuning_failsafe_timeout', newTuning.failsafeTimeout);
      await prefs.setInt(
          'tuning_joystick_dead_zone', newTuning.joystickDeadZone);
      await prefs.setInt(
          'tuning_joystick_sensitivity', newTuning.joystickSensitivity);
    } catch (e) {
      print('Save tuning error: $e');
    }
  }

  // ========== UPDATE INDIVIDUAL VALUES ==========
  void setPwmMax(int value) {
    _tuning = _tuning.copyWith(pwmMax: value);
    notifyListeners();
  }

  void setFrequency(int value) {
    _tuning = _tuning.copyWith(frequency: value);
    notifyListeners();
  }

  void setSpeedNormal(int value) {
    _tuning = _tuning.copyWith(speedNormal: value);
    notifyListeners();
  }

  void setSpeedFast(int value) {
    _tuning = _tuning.copyWith(speedFast: value);
    notifyListeners();
  }

  void setFailsafeTimeout(int value) {
    _tuning = _tuning.copyWith(failsafeTimeout: value);
    notifyListeners();
  }

  void setJoystickDeadZone(int value) {
    _tuning = _tuning.copyWith(joystickDeadZone: value);
    notifyListeners();
  }

  void setJoystickSensitivity(int value) {
    _tuning = _tuning.copyWith(joystickSensitivity: value);
    notifyListeners();
  }

  // ========== RESET TO DEFAULT ==========
  Future<void> resetToDefault() async {
    await updateTuning(TuningModel.defaultSettings());
  }

  // ========== LOAD PRESET ==========
  Future<void> loadPreset(String presetName) async {
    TuningModel preset;

    switch (presetName) {
      case 'arena_kasar':
        preset = TuningModel.arenaKasarPreset();
        break;
      case 'arena_halus':
        preset = TuningModel.arenaHalusPreset();
        break;
      case 'turbo':
        preset = TuningModel.turboPreset();
        break;
      case 'battery_saver':
        preset = TuningModel.batterySaverPreset();
        break;
      default:
        preset = TuningModel.defaultSettings();
    }

    await updateTuning(preset);
  }
}
