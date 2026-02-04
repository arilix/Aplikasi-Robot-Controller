import 'package:flutter/material.dart';
import '../../core/theme/scratch_colors.dart';

class FloatingJoystick extends StatefulWidget {
  final double size;
  final Function(double x, double y) onMove;
  final VoidCallback onStop;

  const FloatingJoystick({
    super.key,
    required this.size,
    required this.onMove,
    required this.onStop,
  });

  @override
  State<FloatingJoystick> createState() => _FloatingJoystickState();
}

class _FloatingJoystickState extends State<FloatingJoystick> {
  Offset? _basePosition;
  Offset _stickOffset = Offset.zero;
  bool _isActive = false;

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _basePosition = details.localPosition;
      _stickOffset = Offset.zero;
      _isActive = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_basePosition == null) return;

    final delta = details.localPosition - _basePosition!;
    final distance = delta.distance;
    final maxDistance = 90.0; // Fixed joystick radius

    setState(() {
      if (distance > maxDistance) {
        _stickOffset = Offset.fromDirection(
          delta.direction,
          maxDistance,
        );
      } else {
        _stickOffset = delta;
      }
    });

    // Calculate normalized coordinates (-1 to 1)
    final x = _stickOffset.dx / maxDistance;
    final y = _stickOffset.dy / maxDistance;

    widget.onMove(x, y);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _basePosition = null;
      _stickOffset = Offset.zero;
      _isActive = false;
    });

    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    final isFullScreen = widget.size == double.infinity;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
        width: widget.size,
        height: widget.size,
        color: Colors.transparent,
        child: Stack(
          children: [
            if (!_isActive)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🕹️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      'Tap anywhere to control',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ScratchColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isActive && _basePosition != null)
              CustomPaint(
                size: Size.infinite,
                painter: JoystickPainter(
                  basePosition: _basePosition!,
                  stickOffset: _stickOffset,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class JoystickPainter extends CustomPainter {
  final Offset basePosition;
  final Offset stickOffset;

  JoystickPainter({
    required this.basePosition,
    required this.stickOffset,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final joystickRadius = 90.0;

    // Base circle
    final basePaint = Paint()
      ..color = ScratchColors.motion.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      basePosition,
      joystickRadius,
      basePaint,
    );

    // Base border
    final baseBorderPaint = Paint()
      ..color = ScratchColors.motion
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      basePosition,
      joystickRadius,
      baseBorderPaint,
    );

    // Stick
    final stickPaint = Paint()
      ..color = ScratchColors.motion
      ..style = PaintingStyle.fill;

    final stickPosition = basePosition + stickOffset;

    // Stick shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      stickPosition + const Offset(2, 2),
      30,
      shadowPaint,
    );

    // Stick
    canvas.drawCircle(stickPosition, 30, stickPaint);

    // Stick border
    final stickBorderPaint = Paint()
      ..color = ScratchColors.motionDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(stickPosition, 30, stickBorderPaint);

    // Center dot
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(stickPosition, 8, centerPaint);
  }

  @override
  bool shouldRepaint(JoystickPainter oldDelegate) {
    return oldDelegate.basePosition != basePosition ||
        oldDelegate.stickOffset != stickOffset;
  }
}
