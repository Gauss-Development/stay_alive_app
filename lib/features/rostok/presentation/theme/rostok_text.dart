import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';

/// Typography for the Росток UI: Fredoka (display) + Plus Jakarta Sans (body).
///
/// Wraps [GoogleFonts] so the two families load without bundling `.ttf`s.
abstract final class RostokText {
  /// Fredoka — headings, numbers, brand wordmark.
  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w600,
    Color color = RostokColors.inkText,
    double height = 1.15,
    double? letterSpacing,
  }) {
    return GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Plus Jakarta Sans — body copy, labels, captions.
  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color color = RostokColors.textMuted,
    double height = 1.4,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
