import 'package:flutter/services.dart';
// import 'package:vibration/vibration.dart';  // Disabled - compatibility issue

enum HapticStrength {
  light,
  medium,
  heavy,
}

class HapticManager {
  static bool _enabled = true;

  // ========== ENABLE/DISABLE HAPTIC ==========
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static bool get isEnabled => _enabled;

  // ========== HAPTIC FEEDBACK ==========
  static Future<void> feedback(HapticStrength strength) async {
    if (!_enabled) return;

    try {
      // Use system haptic feedback only
      switch (strength) {
        case HapticStrength.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticStrength.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticStrength.heavy:
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (e) {
      // Silently fail
      print('Haptic feedback error: $e');
    }
  }

  // ========== PREDEFINED HAPTICS ==========
  static Future<void> light() async => await feedback(HapticStrength.light);
  static Future<void> medium() async => await feedback(HapticStrength.medium);
  static Future<void> heavy() async => await feedback(HapticStrength.heavy);

  // ========== SELECTION CLICK ==========
  static Future<void> selectionClick() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }
}
