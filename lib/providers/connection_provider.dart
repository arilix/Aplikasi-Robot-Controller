import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import '../services/bluetooth_service.dart';
import '../services/command_service.dart';

class ConnectionProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  final CommandService _commandService = CommandService();

  // State
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  List<ScanResult> _scanResults = [];
  String _lastMessage = '';
  int _latency = 0;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isScanning => _isScanning;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<ScanResult> get scanResults => _scanResults;
  String get lastMessage => _lastMessage;
  int get latency => _latency;
  BluetoothService get bluetoothService => _bluetoothService;
  CommandService get commandService => _commandService;

  ConnectionProvider() {
    _initialize();
  }

  // ========== INITIALIZE ==========
  Future<void> _initialize() async {
    await _bluetoothService.initialize();

    // Listen to connection state changes
    _bluetoothService.connectionStateStream.listen((connected) {
      _isConnected = connected;
      _isConnecting = false;

      if (!connected) {
        _connectedDevice = null;
      }

      notifyListeners();
    });

    // Listen to incoming messages
    _bluetoothService.messageStream.listen((message) {
      _lastMessage = message;

      // Handle PONG response for latency
      if (message == 'PONG') {
        _commandService.onPongReceived();
        _latency = _commandService.latencyMs;
      }

      notifyListeners();
    });
  }

  // ========== SCAN DEVICES ==========
  Future<void> startScan() async {
    try {
      _isScanning = true;
      notifyListeners();

      // Listen to scan results
      _bluetoothService.scanDevices().listen((results) {
        _scanResults = results;
        notifyListeners();
      });

      // Auto-stop after timeout
      Future.delayed(const Duration(seconds: 10), () {
        if (_isScanning) {
          stopScan();
        }
      });
    } catch (e) {
      print('Scan error: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  // ========== STOP SCAN ==========
  Future<void> stopScan() async {
    await _bluetoothService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  // ========== GET BONDED DEVICES ==========
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetoothService.getBondedDevices();
  }

  // ========== CONNECT TO DEVICE ==========
  Future<bool> connect(BluetoothDevice device) async {
    _isConnecting = true;
    notifyListeners();

    bool success = await _bluetoothService.connect(device);

    if (success) {
      _connectedDevice = device;
      _isConnected = true;

      // Start periodic ping for latency monitoring
      _startLatencyMonitor();
    }

    _isConnecting = false;
    notifyListeners();

    return success;
  }

  // ========== DISCONNECT ==========
  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
    _connectedDevice = null;
    _isConnected = false;
    notifyListeners();
  }

  // ========== LATENCY MONITOR ==========
  void _startLatencyMonitor() {
    // Ping every 2 seconds to measure latency
    Future.delayed(const Duration(seconds: 2), () {
      if (_isConnected) {
        _commandService.ping();
        _startLatencyMonitor(); // Recursive call
      }
    });
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    _commandService.dispose();
    super.dispose();
  }
}
