import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';

/// The colours that differ between the light and dark «Росток» themes.
///
/// Anything Material 3 already has a role for lives in [scheme]; the handful of
/// fields below cover the surfaces it does not model well enough for us.
final class _Palette {
  const _Palette({
    required this.scheme,
    required this.background,
    required this.card,
    required this.chip,
    required this.textMuted,
    required this.snackBackground,
    required this.snackForeground,
  });

  final ColorScheme scheme;

  /// Scaffold and app bar.
  final Color background;

  /// Raised surfaces: cards, dialogs, sheets, input fills, navigation bar.
  final Color card;

  /// Inset pills sitting on top of [card].
  final Color chip;

  /// Third-level text: hints, unselected labels.
  final Color textMuted;

  final Color snackBackground;
  final Color snackForeground;
}

/// Global «Росток» theme.
abstract final class AppTheme {
  static ThemeData get light => _build(_lightPalette);

  static ThemeData get dark => _build(_darkPalette);

  static const _Palette _lightPalette = _Palette(
    scheme: ColorScheme.light(
      primary: AppColors.dark,
      onPrimary: AppColors.white,
      secondary: AppColors.green,
      onSecondary: AppColors.white,
      tertiary: AppColors.lime,
      onTertiary: AppColors.dark,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.error,
    ),
    background: AppColors.background,
    card: AppColors.white,
    chip: AppColors.surface,
    textMuted: AppColors.textMuted,
    snackBackground: AppColors.dark,
    snackForeground: AppColors.white,
  );

  /// Warm, low-glare dark theme: no pure black, no pure white, same accents.
  /// The primary button flips to lime-on-dark so it stays the loudest thing
  /// on the screen.
  static const _Palette _darkPalette = _Palette(
    scheme: ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.dark,
      secondary: AppColors.green,
      onSecondary: AppColors.dark,
      tertiary: AppColors.lime,
      onTertiary: AppColors.dark,
      surface: AppColors.dark2,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
      error: AppColors.error,
      onError: AppColors.dark,
    ),
    background: AppColors.dark,
    card: AppColors.dark2,
    chip: AppColors.darkChip,
    textMuted: AppColors.textMutedDark,
    snackBackground: AppColors.darkChip,
    snackForeground: AppColors.textPrimaryDark,
  );

  /// Nunito, recoloured for [p]. [AppTextStyles] bakes the light text colours
  /// in, so every entry is re-tinted here instead of trusted as-is.
  static TextTheme _textTheme(_Palette p) {
    final ColorScheme cs = p.scheme;
    return ThemeData.light().textTheme
        .apply(
          fontFamily: AppTextStyles.fontFamily,
          bodyColor: cs.onSurface,
          displayColor: cs.onSurface,
        )
        .copyWith(
          headlineLarge: AppTextStyles.headlineLarge.copyWith(
            color: cs.onSurface,
          ),
          headlineMedium: AppTextStyles.headlineMedium.copyWith(
            color: cs.onSurface,
          ),
          titleLarge: AppTextStyles.titleLarge.copyWith(color: cs.onSurface),
          titleMedium: AppTextStyles.titleMedium.copyWith(color: cs.onSurface),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
          bodySmall: AppTextStyles.bodySmall.copyWith(
            color: cs.onSurfaceVariant,
          ),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: cs.onSurface),
          labelMedium: AppTextStyles.labelMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: p.textMuted),
        );
  }

  static ThemeData _build(_Palette p) {
    final ColorScheme cs = p.scheme;
    final TextTheme textTheme = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      colorScheme: cs,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: p.background,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: p.textMuted,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.secondary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.onSurfaceVariant,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outline),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.chip,
        labelStyle: textTheme.labelMedium,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.secondary,
        linearTrackColor: cs.outline,
        circularTrackColor: cs.outline,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.snackBackground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: p.snackForeground,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outline, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        indicatorColor: cs.tertiary,
        elevation: 0,
        height: 72,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => AppTextStyles.labelMedium.copyWith(
            color: states.contains(WidgetState.selected)
                ? cs.onSurface
                : p.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            // Selected icons sit on the lime indicator, not on the bar.
            color: states.contains(WidgetState.selected)
                ? cs.onTertiary
                : p.textMuted,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      // Otherwise sheets fall back to Material's purple-tinted container roles.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}
