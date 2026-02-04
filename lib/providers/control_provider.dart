import 'package:flutter/foundation.dart';
import '../core/constants/control_modes.dart';

class ControlProvider extends ChangeNotifier {
  ControlMode _controlMode = ControlMode.normal;
  bool _isBoostActive = false;
  bool _isFastSpeed = false;
  String _currentCommand = 'STOP';
  double _joystickX = 0.0;
  double _joystickY = 0.0;

  // Getters
  ControlMode get controlMode => _controlMode;
  bool get isBoostActive => _isBoostActive;
  bool get isFastSpeed => _isFastSpeed;
  String get currentCommand => _currentCommand;
  double get joystickX => _joystickX;
  double get joystickY => _joystickY;

  // ========== SET CONTROL MODE ==========
  void setControlMode(ControlMode mode) {
    _controlMode = mode;
    notifyListeners();
  }

  // ========== TOGGLE CONTROL MODE ==========
  void toggleControlMode() {
    _controlMode = _controlMode == ControlMode.normal
        ? ControlMode.pro
        : ControlMode.normal;
    notifyListeners();
  }

  // ========== SET BOOST ==========
  void setBoost(bool active) {
    _isBoostActive = active;
    notifyListeners();
  }

  // ========== SET SPEED MODE ==========
  void setFastSpeed(bool fast) {
    _isFastSpeed = fast;
    notifyListeners();
  }

  // ========== UPDATE JOYSTICK ==========
  void updateJoystick(double x, double y) {
    _joystickX = x;
    _joystickY = y;
    notifyListeners();
  }

  // ========== UPDATE CURRENT COMMAND ==========
  void updateCurrentCommand(String command) {
    _currentCommand = command;
    notifyListeners();
  }

  // ========== RESET CONTROL ==========
  void reset() {
    _isBoostActive = false;
    _isFastSpeed = false;
    _currentCommand = 'STOP';
    _joystickX = 0.0;
    _joystickY = 0.0;
    notifyListeners();
  }
}
