import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/constants/robot_types.dart';
import '../core/theme/scratch_colors.dart';
import '../providers/robot_provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/garage/robot_card.dart';
import '../widgets/common/scratch_button.dart';
import 'connection_screen.dart';
import 'controller_screen.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check Bluetooth permissions
    final connectionProvider = context.read<ConnectionProvider>();
    await connectionProvider.bluetoothService.initialize();
  }

  Future<void> _autoConnect() async {
    final robotProvider = context.read<RobotProvider>();
    final connectionProvider = context.read<ConnectionProvider>();

    // For Bluetooth Classic (SPP), we need to find paired device by name
    _showMessage('Searching for SOCCER-v2...');

    try {
      // Start a quick scan to find devices
      connectionProvider.startScan();

      // Wait a bit for scan results
      await Future.delayed(const Duration(seconds: 3));

      // Look for SOCCER-v2 or SUMO-v1 in scan results
      final scanResults = connectionProvider.scanResults;
      BluetoothDevice? targetDevice;

      for (var result in scanResults) {
        if (result.device.platformName.contains('SOCCER') ||
            result.device.platformName.contains('SUMO')) {
          targetDevice = result.device;
          break;
        }
      }

      await connectionProvider.stopScan();

      if (targetDevice == null) {
        _showMessage('Robot not found. Please pair ESP32 first.');
        _navigateToConnection();
        return;
      }

      // Connect
      bool success = await connectionProvider.connect(targetDevice);

      if (success) {
        _showMessage('Connected to ${targetDevice.platformName}');
        await robotProvider.saveLastConnectedDevice(
          targetDevice.remoteId.toString(),
          targetDevice.platformName,
        );
        _navigateToController();
      } else {
        _showMessage('Connection failed');
        _navigateToConnection();
      }
    } catch (e) {
      _showMessage('Error: $e');
      _navigateToConnection();
    }
  }

  void _navigateToConnection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConnectionScreen()),
    );
  }

  void _navigateToController() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ControllerScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏁', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'THE ROBOT GARAGE',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ScratchColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🏁', style: TextStyle(fontSize: 24)),
                  ],
                ),

                // Robot selection cards
                Consumer<RobotProvider>(
                  builder: (context, robotProvider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Soccer Robot Card
                        RobotCard(
                          robotType: RobotType.soccer,
                          isSelected: robotProvider.selectedRobotType ==
                              RobotType.soccer,
                          onTap: () {
                            robotProvider.selectRobotType(RobotType.soccer);
                          },
                        ),
                        const SizedBox(width: 24),
                        // Sumo Robot Card
                        RobotCard(
                          robotType: RobotType.sumo,
                          isSelected:
                              robotProvider.selectedRobotType == RobotType.sumo,
                          onTap: () {
                            robotProvider.selectRobotType(RobotType.sumo);
                          },
                        ),
                      ],
                    );
                  },
                ),

                // Last connected info
                Consumer<RobotProvider>(
                  builder: (context, robotProvider, child) {
                    if (robotProvider.lastConnectedDeviceName != null) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ScratchColors.info.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bluetooth_connected,
                                size: 16, color: ScratchColors.info),
                            const SizedBox(width: 6),
                            Text(
                              'Last: ${robotProvider.lastConnectedDeviceName}',
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                color: ScratchColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox(height: 20);
                  },
                ),

                // Connection buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScratchButton(
                      label: 'AUTO-CONNECT',
                      emoji: '🟢',
                      color: ScratchColors.success,
                      width: 170,
                      height: 50,
                      fontSize: 14,
                      onPressed: _autoConnect,
                    ),
                    const SizedBox(width: 16),
                    ScratchButton(
                      label: 'SCAN DEVICES',
                      emoji: '📋',
                      color: ScratchColors.motion,
                      width: 170,
                      height: 50,
                      fontSize: 14,
                      onPressed: _navigateToConnection,
                    ),
                  ],
                ),

                // Version and developer info
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'v1.6.2',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            color: ScratchColors.textSecondary.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          'Developed by arilix',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            color: ScratchColors.textSecondary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
