import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/robot_types.dart';

class RobotProvider extends ChangeNotifier {
  RobotType _selectedRobotType = RobotType.soccer;
  String? _lastConnectedDeviceAddress;
  String? _lastConnectedDeviceName;

  // Getters
  RobotType get selectedRobotType => _selectedRobotType;
  String? get lastConnectedDeviceAddress => _lastConnectedDeviceAddress;
  String? get lastConnectedDeviceName => _lastConnectedDeviceName;

  RobotProvider() {
    _loadPreferences();
  }

  // ========== LOAD PREFERENCES ==========
  Future<void> _loadPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? robotTypeStr = prefs.getString('selected_robot_type');
      if (robotTypeStr != null) {
        _selectedRobotType = RobotType.values.firstWhere(
          (e) => e.toString() == robotTypeStr,
          orElse: () => RobotType.soccer,
        );
      }

      _lastConnectedDeviceAddress = prefs.getString('last_device_address');
      _lastConnectedDeviceName = prefs.getString('last_device_name');

      notifyListeners();
    } catch (e) {
      print('Load preferences error: $e');
    }
  }

  // ========== SELECT ROBOT TYPE ==========
  Future<void> selectRobotType(RobotType type) async {
    _selectedRobotType = type;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_robot_type', type.toString());
    } catch (e) {
      print('Save robot type error: $e');
    }
  }

  // ========== SAVE LAST CONNECTED DEVICE ==========
  Future<void> saveLastConnectedDevice(String address, String name) async {
    _lastConnectedDeviceAddress = address;
    _lastConnectedDeviceName = name;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_address', address);
      await prefs.setString('last_device_name', name);
    } catch (e) {
      print('Save last device error: $e');
    }
  }

  // ========== CLEAR LAST CONNECTED DEVICE ==========
  Future<void> clearLastConnectedDevice() async {
    _lastConnectedDeviceAddress = null;
    _lastConnectedDeviceName = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_device_address');
      await prefs.remove('last_device_name');
    } catch (e) {
      print('Clear last device error: $e');
    }
  }
}
