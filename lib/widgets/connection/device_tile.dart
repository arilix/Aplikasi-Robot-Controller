import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/theme/scratch_colors.dart';

class DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final int rssi;
  final VoidCallback onConnect;
  final bool isConnecting;

  const DeviceTile({
    Key? key,
    required this.device,
    required this.rssi,
    required this.onConnect,
    this.isConnecting = false,
  }) : super(key: key);

  String _getSignalStrength() {
    if (rssi >= -60) {
      return '▂▃▅▇ Strong';
    } else if (rssi >= -75) {
      return '▂▃▅_ Good';
    } else if (rssi >= -90) {
      return '▂▃__ Fair';
    } else {
      return '▂___ Weak';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Robot icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ScratchColors.motion.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.platformName.isNotEmpty
                        ? device.platformName
                        : 'Unknown Device',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ScratchColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${device.remoteId}',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: ScratchColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.signal_cellular_alt,
                          size: 14, color: ScratchColors.success),
                      const SizedBox(width: 4),
                      Text(
                        _getSignalStrength(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: ScratchColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Connect button
            isConnecting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: onConnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ScratchColors.motion,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text('CONNECT'),
                        SizedBox(width: 4),
                        Text('🔌', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
