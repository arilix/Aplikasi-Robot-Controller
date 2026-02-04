import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/theme/scratch_colors.dart';
import '../providers/connection_provider.dart';
import '../providers/robot_provider.dart';
import '../widgets/connection/device_tile.dart';
import 'controller_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  String? _connectingDeviceId;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    final connectionProvider = context.read<ConnectionProvider>();
    connectionProvider.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    final connectionProvider = context.read<ConnectionProvider>();
    await connectionProvider.startScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _connectingDeviceId = device.remoteId.toString());

    final connectionProvider = context.read<ConnectionProvider>();
    final robotProvider = context.read<RobotProvider>();

    // Stop scanning before connecting
    await connectionProvider.stopScan();

    bool success = await connectionProvider.connect(device);

    setState(() => _connectingDeviceId = null);

    if (success) {
      // Save as last connected device
      await robotProvider.saveLastConnectedDevice(
        device.remoteId.toString(),
        device.platformName,
      );

      // Navigate to controller
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ControllerScreen()),
        );
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to ${device.platformName}'),
            backgroundColor: ScratchColors.danger,
          ),
        );
      }
      // Resume scanning after failed connection
      _startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ScratchColors.background,
                ScratchColors.motion.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<ConnectionProvider>(
                  builder: (context, connectionProvider, child) {
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          connectionProvider.isScanning
                              ? '🔍 SCANNING FOR ROBOTS...'
                              : '📡 AVAILABLE DEVICES',
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ScratchColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (connectionProvider.isScanning)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh,
                                size: 28, color: ScratchColors.motion),
                            onPressed: _startScan,
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Device list
              Expanded(
                child: Consumer<ConnectionProvider>(
                  builder: (context, connectionProvider, child) {
                    final scanResults = connectionProvider.scanResults;
                    final isScanning = connectionProvider.isScanning;

                    if (isScanning && scanResults.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Scanning for devices...'),
                          ],
                        ),
                      );
                    }

                    if (scanResults.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('😕', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text(
                              'No robot devices found',
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ScratchColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Make sure your robot is:\n• Powered ON\n• Bluetooth enabled\n• Within range',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                color: ScratchColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: scanResults.length,
                      itemBuilder: (context, index) {
                        final scanResult = scanResults[index];
                        final device = scanResult.device;
                        return DeviceTile(
                          device: device,
                          rssi: scanResult.rssi,
                          isConnecting:
                              _connectingDeviceId == device.remoteId.toString(),
                          onConnect: () => _connectToDevice(device),
                        );
                      },
                    );
                  },
                ),
              ),

              // Tip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ScratchColors.info.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: ScratchColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '💡 Tip: Make sure robot is powered on and within 10 meters',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: ScratchColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
