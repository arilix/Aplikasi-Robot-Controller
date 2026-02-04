import 'dart:async';
import 'bluetooth_service.dart';
import '../core/constants/commands.dart';

class CommandService {
  final BluetoothService _bluetoothService = BluetoothService();

  // Command rate limiter
  Timer? _commandTimer;
  String? _lastCommand;
  final int _commandRateMs = 50; // 20Hz (50ms interval)

  // Latency tracking
  DateTime? _lastPingSent;
  int _latencyMs = 0;

  // Getters
  int get latencyMs => _latencyMs;

  // ========== SEND MOVEMENT COMMAND ==========
  void sendMovement(double x, double y) {
    // Convert joystick coordinates to robot commands
    // x: -1.0 (left) to 1.0 (right)
    // y: -1.0 (up/forward) to 1.0 (down/backward)

    String command = _joystickToCommand(x, y);

    // Only send if command changed
    if (command != _lastCommand) {
      _sendThrottled(command);
      _lastCommand = command;
    }
  }

  // ========== JOYSTICK TO COMMAND CONVERTER ==========
  String _joystickToCommand(double x, double y) {
    const double threshold = 0.3; // Dead zone

    // Check if joystick is in dead zone
    if (x.abs() < threshold && y.abs() < threshold) {
      return RobotCommands.stop;
    }

    // Determine direction based on joystick position
    // Diagonal movements (8 directions)
    if (y < -threshold) {
      // Forward direction
      if (x < -threshold) {
        return RobotCommands.majuKiri; // Forward-Left
      } else if (x > threshold) {
        return RobotCommands.majuKanan; // Forward-Right
      } else {
        return RobotCommands.maju; // Forward
      }
    } else if (y > threshold) {
      // Backward direction
      if (x < -threshold) {
        return RobotCommands.mundurKiri; // Backward-Left
      } else if (x > threshold) {
        return RobotCommands.mundurKanan; // Backward-Right
      } else {
        return RobotCommands.mundur; // Backward
      }
    } else {
      // Left-Right only
      if (x < -threshold) {
        return RobotCommands.kiri; // Left
      } else if (x > threshold) {
        return RobotCommands.kanan; // Right
      }
    }

    return RobotCommands.stop;
  }

  // ========== THROTTLED SEND (RATE LIMITING) ==========
  void _sendThrottled(String command) {
    _commandTimer?.cancel();

    // Send immediately
    _bluetoothService.sendCommandNoWait(command);

    // Set timer to prevent flooding
    _commandTimer = Timer(Duration(milliseconds: _commandRateMs), () {
      // Timer expired, ready for next command
    });
  }

  // ========== SEND IMMEDIATE COMMAND ==========
  Future<bool> sendCommand(String command) async {
    return await _bluetoothService.sendCommand(command);
  }

  // ========== SEND SPEED COMMAND ==========
  Future<bool> setSpeedMode(bool isFast) async {
    String command =
        isFast ? RobotCommands.speedFast : RobotCommands.speedNormal;
    return await sendCommand(command);
  }

  // ========== SEND BOOST COMMAND ==========
  Future<bool> setBoost(bool enabled) async {
    String command = enabled ? RobotCommands.boostOn : RobotCommands.boostOff;
    return await sendCommand(command);
  }

  // ========== SEND STOP COMMAND ==========
  Future<bool> stop() async {
    _lastCommand = RobotCommands.stop;
    return await sendCommand(RobotCommands.stop);
  }

  // ========== SEND KICK COMMAND ==========
  Future<bool> kick() async {
    return await sendCommand(RobotCommands.kick);
  }

  // ========== SEND TUNING COMMAND ==========
  Future<bool> sendTuning({
    required int pwmMax,
    required int frequency,
    required int speedNormal,
    required int speedFast,
    required int failsafeTimeout,
  }) async {
    String command = RobotCommands.tuning(
      pwmMax: pwmMax,
      frequency: frequency,
      speedNormal: speedNormal,
      speedFast: speedFast,
      failsafeTimeout: failsafeTimeout,
    );

    return await sendCommand(command);
  }

  // ========== PING (LATENCY TEST) ==========
  Future<void> ping() async {
    _lastPingSent = DateTime.now();
    await sendCommand(RobotCommands.ping);
  }

  // ========== HANDLE PONG RESPONSE ==========
  void onPongReceived() {
    if (_lastPingSent != null) {
      _latencyMs = DateTime.now().difference(_lastPingSent!).inMilliseconds;
      print('Latency: ${_latencyMs}ms');
    }
  }

  // ========== DISPOSE ==========
  void dispose() {
    _commandTimer?.cancel();
  }
}
