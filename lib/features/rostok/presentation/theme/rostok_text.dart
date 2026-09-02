import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Typography compatibility layer for the `rostok` feature screens.
///
/// Delegates to Nunito (the app-wide family) so the whole product shares a
/// single type system.
abstract final class RostokText {
  /// Headings, numbers, brand wordmark.
  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textPrimary,
    double height = 1.15,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: size,
      // Display text in Росток is always bold and confident.
      fontWeight: weight.value < FontWeight.w700.value
          ? FontWeight.w700
          : weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Body copy, labels, captions.
  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textSecondary,
    double height = 1.4,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
