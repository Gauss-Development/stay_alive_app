import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Compatibility layer for the `rostok` feature screens.
///
/// All values delegate to the app-wide [AppColors] design tokens so the whole
/// product shares a single colour system.
abstract final class RostokColors {
  // Surfaces
  static const Color surface = AppColors.background;
  static const Color card = AppColors.white;
  static const Color chipBg = AppColors.surface;
  static const Color hatch = AppColors.mutedGreen;
  static const Color avatarBg = AppColors.mutedGreen;

  // Ink / dark panels
  static const Color ink = AppColors.dark;
  static const Color inkText = AppColors.textPrimary;
  static const Color darkChip = AppColors.darkChip;
  static const Color ringTrack = AppColors.darkChip;

  // Accents
  static const Color accent = AppColors.lime;
  static const Color accentPurple = AppColors.purple;
  static const Color accentBlue = AppColors.blue;
  static const Color accentOrange = AppColors.orange;
  static const Color mascot = AppColors.green;

  // Text
  static const Color textMuted = AppColors.textSecondary;
  static const Color textFaint = AppColors.textMuted;
  static const Color textOnDarkMuted = AppColors.textMuted;
  static const Color chipText = AppColors.textPrimary;

  // Borders
  static const Color fieldBorder = AppColors.border;
  static const Color hairline = AppColors.border;

  // Reward screen (dark radial)
  static const Color rewardTop = AppColors.dark2;
  static const Color rewardBottom = AppColors.dark;

  // Confetti palette
  static const List<Color> confetti = <Color>[
    accent,
    AppColors.purple,
    AppColors.blue,
    AppColors.orange,
    AppColors.softYellow,
  ];
}

/// Shared radii, shadows and spacing for the Росток UI.
abstract final class RostokDimens {
  static const double screenPadding = 16;

  static const BorderRadius card = BorderRadius.all(Radius.circular(24));
  static const BorderRadius panel = BorderRadius.all(Radius.circular(28));
  static const BorderRadius row = BorderRadius.all(Radius.circular(20));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> buttonShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
  ];
}
