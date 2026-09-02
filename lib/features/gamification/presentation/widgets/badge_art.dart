import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';

/// Maps [BadgeId] to the generated artwork in `assets/badges/`.
/// File names follow the art batch (see assets/badges/manifest.json), which
/// diverges from enum names for four badges.
extension BadgeAsset on BadgeId {
  String get assetPath {
    final String file = switch (this) {
      BadgeId.weekStreak => 'sevenDayStreak',
      BadgeId.ironWill => 'thirtyDayIronWill',
      BadgeId.centurion => 'hundredDaysCenturion',
      BadgeId.patron => 'premiumPatron',
      // Borrowed art until dedicated illustrations land (see manifest.json).
      // Drop rainbowPlate.png / nightOwl.png into assets/badges/ and delete
      // these two lines — the default arm picks them up by enum name.
      BadgeId.rainbowPlate => 'perfectDay',
      BadgeId.nightOwl => 'earlyBird',
      _ => name,
    };
    return 'assets/badges/$file.png';
  }
}

/// Badge medallion artwork with a locked state (greyscale + faded) and an
/// emoji fallback if the asset ever fails to load.
class BadgeArt extends StatelessWidget {
  const BadgeArt({
    required this.id,
    required this.fallbackEmoji,
    this.size = 44,
    this.unlocked = true,
    super.key,
  });

  final BadgeId id;
  final String fallbackEmoji;
  final double size;
  final bool unlocked;

  static const ColorFilter _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      id.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => Text(
        fallbackEmoji,
        style: TextStyle(fontSize: size * 0.62),
      ),
    );

    if (unlocked) {
      return image;
    }
    return Opacity(
      opacity: 0.4,
      child: ColorFiltered(colorFilter: _greyscale, child: image),
    );
  }
}
