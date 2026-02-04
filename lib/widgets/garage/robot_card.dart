import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/robot_types.dart';
import '../../core/theme/scratch_colors.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/haptic_manager.dart';

class RobotCard extends StatefulWidget {
  final RobotType robotType;
  final bool isSelected;
  final VoidCallback onTap;

  const RobotCard({
    Key? key,
    required this.robotType,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RobotCard> createState() => _RobotCardState();
}

class _RobotCardState extends State<RobotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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

  Color _getCardColor() {
    switch (widget.robotType) {
      case RobotType.soccer:
        return ScratchColors.motion;
      case RobotType.sumo:
        return ScratchColors.looks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        SoundManager.playPop();
        HapticManager.light();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 240,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(color: cardColor, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Robot icon image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.robotType == RobotType.soccer
                        ? 'assets/images/Icon_soccer.png'
                        : 'assets/images/Icon_sumobot.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Robot name
              Text(
                widget.robotType.displayName,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ScratchColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Description
              Text(
                widget.robotType.description,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: ScratchColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
