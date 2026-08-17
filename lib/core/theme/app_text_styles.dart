import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Typography tokens built on Manrope (via `google_fonts`).
///
/// Styles are exposed as getters (not consts) because [GoogleFonts] resolves
/// the family at runtime; they are still cheap to call.
abstract final class AppTextStyles {
  static TextStyle _manrope({
    required double size,
    required FontWeight weight,
    required double height,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get headlineLarge =>
      _manrope(size: 32, weight: FontWeight.w800, height: 1.05);

  static TextStyle get headlineMedium =>
      _manrope(size: 24, weight: FontWeight.w800, height: 1.1);

  static TextStyle get titleLarge =>
      _manrope(size: 20, weight: FontWeight.w800, height: 1.15);

  static TextStyle get titleMedium =>
      _manrope(size: 16, weight: FontWeight.w800, height: 1.2);

  static TextStyle get bodyLarge =>
      _manrope(size: 16, weight: FontWeight.w600, height: 1.35);

  static TextStyle get bodyMedium => _manrope(
    size: 14,
    weight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => _manrope(
    size: 12,
    weight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge =>
      _manrope(size: 14, weight: FontWeight.w800, height: 1.2);

  static TextStyle get labelMedium => _manrope(
    size: 12,
    weight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => _manrope(
    size: 10,
    weight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  /// Big accent numbers — points, XP.
  static TextStyle get points => _manrope(
    size: 26,
    weight: FontWeight.w900,
    height: 1,
    color: AppColors.lime,
  );
}
