import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/scratch_colors.dart';
import '../core/utils/haptic_manager.dart';
import '../providers/connection_provider.dart';
import '../providers/control_provider.dart';
import '../widgets/common/scratch_button.dart';
import '../widgets/controller/floating_joystick.dart';
import 'garage_screen.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  @override
  void initState() {
    super.initState();
    _listenToConnectionState();
  }

  void _listenToConnectionState() {
    final connectionProvider = context.read<ConnectionProvider>();

    connectionProvider.bluetoothService.connectionStateStream
        .listen((isConnected) {
      if (!isConnected && mounted) {
        // Disconnected, go back to garage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Robot disconnected'),
            backgroundColor: ScratchColors.danger,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GarageScreen()),
        );
      }
    });
  }

  void _handleJoystickMove(double x, double y) {
    final connectionProvider = context.read<ConnectionProvider>();
    final controlProvider = context.read<ControlProvider>();

    // Update UI
    controlProvider.updateJoystick(x, y);

    // Send command to robot
    connectionProvider.commandService.sendMovement(x, y);
  }

  void _handleJoystickStop() {
    final connectionProvider = context.read<ConnectionProvider>();
    final controlProvider = context.read<ControlProvider>();

    controlProvider.updateJoystick(0, 0);
    connectionProvider.commandService.stop();
  }

  Future<void> _handleBoost() async {
    final connectionProvider = context.read<ConnectionProvider>();
    final controlProvider = context.read<ControlProvider>();

    final newState = !controlProvider.isBoostActive;
    controlProvider.setBoost(newState);
    await connectionProvider.commandService.setBoost(newState);
  }

  Future<void> _disconnect() async {
    final connectionProvider = context.read<ConnectionProvider>();
    await connectionProvider.disconnect();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GarageScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            _buildStatusBar(context),
            Expanded(
              child: Stack(
                children: [
                  _buildJoystickArea(context),
                  _buildBoostButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ScratchColors.control,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_connected, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<ConnectionProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.connectedDevice?.platformName ?? 'SOCCER-v2',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Consumer<ControlProvider>(
            builder: (context, provider, child) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: provider.isBoostActive
                      ? ScratchColors.looks
                      : ScratchColors.operators,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.isBoostActive ? '⚡ NORMAL' : '🚀 BOOST',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Consumer<ConnectionProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    color: provider.latency < 100
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.latency}ms',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: _disconnect,
            tooltip: 'Disconnect',
          ),
        ],
      ),
    );
  }

  Widget _buildJoystickArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ScratchColors.motion.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: FloatingJoystick(
        size: double.infinity,
        onMove: _handleJoystickMove,
        onStop: _handleJoystickStop,
      ),
    );
  }

  Widget _buildBoostButton(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Consumer<ControlProvider>(
        builder: (context, provider, child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleBoost,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: provider.isBoostActive
                      ? ScratchColors.looks
                      : ScratchColors.operators,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🚀',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
