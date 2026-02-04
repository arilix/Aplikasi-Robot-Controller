import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  // Singleton pattern
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Connection
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription<List<int>>? _dataSubscription;

  // Stream controllers
  final StreamController<String> _messageStreamController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  // Getters
  Stream<String> get messageStream => _messageStreamController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  bool get isConnected => _connectedDevice != null;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // ========== INITIALIZE BLUETOOTH ==========
  Future<bool> initialize() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        print("Bluetooth not supported by this device");
        return false;
      }

      // Turn on Bluetooth if it's off (Android only, iOS auto-prompts)
      if (await FlutterBluePlus.adapterState.first !=
          BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
      }

      return true;
    } catch (e) {
      print('Bluetooth initialization error: $e');
      return false;
    }
  }

  // ========== GET BONDED DEVICES ==========
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      // Return empty list as flutter_blue_plus handles devices differently
      // Devices will be discovered through scanning
      return [];
    } catch (e) {
      print('Error getting bonded devices: $e');
      return [];
    }
  }

  // ========== SCAN FOR DEVICES ==========
  Stream<List<ScanResult>> scanDevices(
      {Duration timeout = const Duration(seconds: 10)}) {
    // Start scanning
    FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );

    // Return scan results stream
    return FlutterBluePlus.scanResults;
  }

  // ========== STOP SCANNING ==========
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // ========== CONNECT TO DEVICE ==========
  Future<bool> connect(BluetoothDevice device) async {
    try {
      // Disconnect if already connected
      if (_connectedDevice != null) {
        await disconnect();
      }

      print('Connecting to ${device.platformName}...');

      // Connect to device
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;

      // Listen to connection state changes
      device.connectionState.listen((BluetoothConnectionState state) {
        bool connected = state == BluetoothConnectionState.connected;
        _connectionStateController.add(connected);

        if (!connected) {
          print('Device disconnected');
          _cleanup();
        }
      });

      // Discover services
      var services = await device.discoverServices();

      // Find Serial Port Profile (SPP) service - typically 00001101-0000-1000-8000-00805F9B34FB
      // Or find the first writable characteristic
      for (var service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // Look for characteristic that supports write and notify
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            _txCharacteristic = characteristic;
            print('Found TX characteristic: ${characteristic.uuid}');
          }

          // Subscribe to notifications if available
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            _dataSubscription = characteristic.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                String message = utf8.decode(value);
                _messageStreamController.add(message);
              }
            });
            print('Subscribed to RX characteristic: ${characteristic.uuid}');
          }
        }
      }

      if (_txCharacteristic == null) {
        print('No writable characteristic found');
        await disconnect();
        return false;
      }

      _connectionStateController.add(true);
      print('Connected to ${device.platformName}');
      return true;
    } catch (e) {
      print('Connection error: $e');
      _cleanup();
      return false;
    }
  }

  // ========== DISCONNECT ==========
  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      _dataSubscription = null;

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        print('Disconnected from device');
      }

      _cleanup();
    } catch (e) {
      print('Disconnect error: $e');
      _cleanup();
    }
  }

  // ========== CLEANUP ==========
  void _cleanup() {
    _connectedDevice = null;
    _txCharacteristic = null;
    _connectionStateController.add(false);
  }

  // ========== SEND COMMAND ==========
  Future<bool> sendCommand(String command) async {
    if (!isConnected || _txCharacteristic == null) {
      print('Not connected or no TX characteristic');
      return false;
    }

    try {
      // Ensure command ends with newline
      if (!command.endsWith('\n')) {
        command += '\n';
      }

      List<int> bytes = utf8.encode(command);

      // Write with response
      if (_txCharacteristic!.properties.write) {
        await _txCharacteristic!.write(bytes, withoutResponse: false);
      }
      // Write without response (faster)
      else if (_txCharacteristic!.properties.writeWithoutResponse) {
        await _txCharacteristic!.write(bytes, withoutResponse: true);
      }

      return true;
    } catch (e) {
      print('Send command error: $e');
      return false;
    }
  }

  // ========== SEND COMMAND WITHOUT WAITING ==========
  Future<void> sendCommandNoWait(String command) async {
    if (!isConnected || _txCharacteristic == null) return;

    try {
      if (!command.endsWith('\n')) {
        command += '\n';
      }

      List<int> bytes = utf8.encode(command);

      // Always use writeWithoutResponse for non-blocking operation
      if (_txCharacteristic!.properties.writeWithoutResponse) {
        await _txCharacteristic!.write(bytes, withoutResponse: true);
      } else if (_txCharacteristic!.properties.write) {
        // Fallback to write with response
        await _txCharacteristic!.write(bytes, withoutResponse: false);
      }
    } catch (e) {
      print('Send command no-wait error: $e');
    }
  }

  // ========== DISPOSE ==========
  void dispose() {
    _messageStreamController.close();
    _connectionStateController.close();
    disconnect();
  }
}
