import 'package:flutter/material.dart';

/// Design tokens: the «Росток» colour system.
///
/// Single source of truth for every colour in the app. Screens and widgets
/// must not hardcode colours — always reference these tokens.
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFFEEF0E7);
  static const Color surface = Color(0xFFF8F8F3);
  static const Color white = Color(0xFFFFFFFF);

  // Dark panels / hero cards / primary CTA on light backgrounds
  static const Color dark = Color(0xFF11140B);
  static const Color dark2 = Color(0xFF1B2112);

  /// Chip / pill background on top of dark panels.
  static const Color darkChip = Color(0xFF2A2E20);

  // Accents
  static const Color lime = Color(0xFFD2EC3F);
  static const Color green = Color(0xFF83C63F);
  static const Color mutedGreen = Color(0xFFC8DDBE);

  static const Color border = Color(0xFFE3E7DA);

  // Text
  static const Color textPrimary = Color(0xFF11140B);
  static const Color textSecondary = Color(0xFF6B7061);
  static const Color textMuted = Color(0xFF9AA08E);

  // Decorative palette — achievements, rewards, badges, soft categories only.
  static const Color orange = Color(0xFFFFA63D);
  static const Color blue = Color(0xFF7FB7FF);
  static const Color purple = Color(0xFFD9C8FF);
  static const Color softYellow = Color(0xFFFFEAA7);
  static const Color softRed = Color(0xFFFFB4A8);

  /// Calm error tone (no aggressive reds).
  static const Color error = Color(0xFFD96C5B);

  /// Soft tints for food / category icon circles, cycled by index.
  static const List<Color> foodTints = <Color>[
    Color(0xFFEFE3C8),
    Color(0xFFE3EAF3),
    Color(0xFFDCEBD0),
    Color(0xFFF3E0DC),
    Color(0xFFEDE4F5),
    Color(0xFFF6EBCF),
  ];

  /// Decorative badge tints, cycled by index.
  static const List<Color> badgeTints = <Color>[
    lime,
    purple,
    blue,
    softYellow,
    mutedGreen,
    softRed,
  ];
}
