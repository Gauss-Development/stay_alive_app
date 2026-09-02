import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Theme-aware typography and colours.
///
/// Widgets must read text styles from here, never from [AppTextStyles]
/// directly: the raw tokens bake the light-theme ink, so a direct reference
/// renders near-black text on the dark background.
extension AppThemeX on BuildContext {
  /// Text styles already tinted for the active theme.
  TextTheme get text => Theme.of(this).textTheme;

  /// Colours of the active theme. `onSurface` is primary ink,
  /// `onSurfaceVariant` is the secondary/muted ink.
  ColorScheme get colors => Theme.of(this).colorScheme;
}

/// Raw typography tokens built on Nunito, bundled in `assets/fonts/`.
///
/// Shape only — [AppTheme] applies the palette's ink on top, so these are for
/// theme construction. In widgets use `context.text.*` instead.
abstract final class AppTextStyles {
  /// Bundled family name — must match the `fonts:` entry in pubspec.yaml.
  static const String fontFamily = 'Nunito';

  static TextStyle _nunito({
    required double size,
    required FontWeight weight,
    required double height,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get headlineLarge =>
      _nunito(size: 32, weight: FontWeight.w800, height: 1.05);

  static TextStyle get headlineMedium =>
      _nunito(size: 24, weight: FontWeight.w800, height: 1.1);

  static TextStyle get titleLarge =>
      _nunito(size: 20, weight: FontWeight.w800, height: 1.15);

  static TextStyle get titleMedium =>
      _nunito(size: 16, weight: FontWeight.w800, height: 1.2);

  static TextStyle get bodyLarge =>
      _nunito(size: 16, weight: FontWeight.w600, height: 1.35);

  static TextStyle get bodyMedium => _nunito(
    size: 14,
    weight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => _nunito(
    size: 12,
    weight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge =>
      _nunito(size: 14, weight: FontWeight.w800, height: 1.2);

  static TextStyle get labelMedium => _nunito(
    size: 12,
    weight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => _nunito(
    size: 10,
    weight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  /// Big accent numbers — points, XP.
  static TextStyle get points => _nunito(
    size: 26,
    weight: FontWeight.w900,
    height: 1,
    color: AppColors.lime,
  );
}
