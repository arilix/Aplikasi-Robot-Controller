import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scratch_colors.dart';

class ScratchTextStyles {
  // Headings
  static TextStyle heading1(BuildContext context, {Color? color}) {
    return GoogleFonts.fredoka(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color ?? ScratchColors.textPrimary,
    );
  }

  static TextStyle heading2(BuildContext context, {Color? color}) {
    return GoogleFonts.fredoka(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: color ?? ScratchColors.textPrimary,
    );
  }

  static TextStyle heading3(BuildContext context, {Color? color}) {
    return GoogleFonts.fredoka(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? ScratchColors.textPrimary,
    );
  }

  // Body
  static TextStyle body(BuildContext context, {Color? color}) {
    return GoogleFonts.quicksand(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: color ?? ScratchColors.textPrimary,
    );
  }

  static TextStyle bodyBold(BuildContext context, {Color? color}) {
    return GoogleFonts.quicksand(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: color ?? ScratchColors.textPrimary,
    );
  }

  // Button
  static TextStyle button(BuildContext context, {Color? color}) {
    return GoogleFonts.fredoka(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: color ?? ScratchColors.textWhite,
    );
  }

  // Caption
  static TextStyle caption(BuildContext context, {Color? color}) {
    return GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color ?? ScratchColors.textSecondary,
    );
  }
}
