import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/scratch_colors.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/haptic_manager.dart';

class ScratchButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final Color color;
  final double? width;
  final double? height;
  final double? fontSize;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final bool compact;
  final HapticStrength vibrationStrength;
  final bool enabled;

  const ScratchButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.emoji,
    this.width,
    this.height,
    this.fontSize,
    this.onLongPress,
    this.compact = false,
    this.vibrationStrength = HapticStrength.medium,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ScratchButton> createState() => _ScratchButtonState();
}

class _ScratchButtonState extends State<ScratchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();

    // Play sound and haptic
    SoundManager.playPop();
    HapticManager.feedback(widget.vibrationStrength);

    // Call callback
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.enabled ? widget.color : Colors.grey,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: _isPressed ? 2 : 8,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.emoji != null) ...[
                  Text(
                    widget.emoji!,
                    style: TextStyle(fontSize: (widget.fontSize ?? 16) + 4),
                  ),
                  if (!widget.compact) const SizedBox(width: 8),
                ],
                if (widget.icon != null && !widget.compact) ...[
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: (widget.fontSize ?? 16) + 2,
                  ),
                  const SizedBox(width: 8),
                ],
                if (!widget.compact)
                  Text(
                    widget.label,
                    style: GoogleFonts.fredoka(
                      fontSize: widget.fontSize ?? 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
