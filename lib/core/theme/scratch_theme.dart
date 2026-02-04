import 'package:flutter/material.dart';
import 'scratch_colors.dart';

class ScratchTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: ScratchColors.motion,
      scaffoldBackgroundColor: ScratchColors.background,
      colorScheme: const ColorScheme.light(
        primary: ScratchColors.motion,
        secondary: ScratchColors.events,
        error: ScratchColors.danger,
        surface: ScratchColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ScratchColors.control,
        elevation: 4,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ScratchColors.motion,
          foregroundColor: ScratchColors.textWhite,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
