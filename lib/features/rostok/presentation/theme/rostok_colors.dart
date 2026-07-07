import 'package:flutter/material.dart';

/// Design tokens for the "Росток" (Sprout) UI, ported from `Росток.dc.html`.
///
/// Scoped to the `rostok` feature so the existing [AppTheme] stays untouched.
abstract final class RostokColors {
  // Surfaces
  static const Color surface = Color(0xFFF4F4EE); // screen + primary card bg
  static const Color card = Color(0xFFFFFFFF); // elevated white sub-cards
  static const Color chipBg = Color(0xFFEEF3E6); // inactive pill background
  static const Color hatch = Color(0xFFE5ECD9); // hatched placeholder blocks
  static const Color avatarBg = Color(0xFFDFE7D4); // hatched avatar background

  // Ink / dark panels
  static const Color ink = Color(0xFF181811); // dark cards, primary buttons
  static const Color inkText = Color(0xFF20261A); // near-black text
  static const Color darkChip = Color(0xFF2A2A20); // chip on dark panels
  static const Color ringTrack = Color(0xFF2A2A20); // unfilled ring on dark

  // Accent (design default: lime). Alternatives kept for reference/theming.
  static const Color accent = Color(0xFFC9E04A);
  static const Color accentPurple = Color(0xFFB98CF0);
  static const Color accentBlue = Color(0xFF8BB0F5);
  static const Color accentOrange = Color(0xFFF0956E);
  static const Color mascot = Color(0xFF8FC63D); // leaf mascot green

  // Text
  static const Color textMuted = Color(0xFF5B6851);
  static const Color textFaint = Color(0xFF8A9780);
  static const Color textOnDarkMuted = Color(0xFF9AA08E);
  static const Color chipText = Color(0xFF3F4B36);

  // Borders
  static const Color fieldBorder = Color(0xFFDCDCD2);
  static const Color hairline = Color(0xFFE0E0D6);

  // Reward screen (dark radial)
  static const Color rewardTop = Color(0xFF242B1B);
  static const Color rewardBottom = Color(0xFF14160F);

  // Confetti palette
  static const List<Color> confetti = <Color>[
    accent,
    Color(0xFFE6DCF5),
    accentBlue,
    accentOrange,
    Color(0xFF8BB0F5),
  ];

  // Canvas gradient behind the mockup frames (rarely used on-device).
  static const List<Color> canvasGradient = <Color>[
    Color(0xFFD3E5C7),
    Color(0xFFC2D8B3),
    Color(0xFFB8D1A7),
  ];
}

/// Shared radii, shadows and spacing for the Росток UI.
abstract final class RostokDimens {
  static const double screenPadding = 20;

  static const BorderRadius card = BorderRadius.all(Radius.circular(24));
  static const BorderRadius panel = BorderRadius.all(Radius.circular(30));
  static const BorderRadius row = BorderRadius.all(Radius.circular(22));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(16));

  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0D3C5032), blurRadius: 14, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> buttonShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0F3C5032), blurRadius: 10, offset: Offset(0, 3)),
  ];
}
