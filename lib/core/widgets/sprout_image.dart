import 'package:flutter/material.dart';

/// Static sprout mascot artwork (`assets/sprout/`, 1x/2x/3x densities).
///
/// Moods are named after the artwork. The GAU-416 loop maps them as:
/// [curious] ≙ waiting (day untouched — hopeful, never guilt-tripping),
/// [cheer] ≙ missed_you / celebration, [sleeping] ≙ night hours.
enum SproutMood {
  happy('sprout_happy'),
  curious('sprout_curious'),
  sleeping('sprout_sleep'),
  cheer('sprout_cheer');

  const SproutMood(this._fileName);

  final String _fileName;

  String get assetPath => 'assets/sprout/$_fileName.png';
}

/// Renders the sprout in the given [mood] with a soft cross-fade on change.
class SproutImage extends StatelessWidget {
  const SproutImage({
    required this.mood,
    this.size = 96,
    super.key,
  });

  final SproutMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Image.asset(
        mood.assetPath,
        key: ValueKey<SproutMood>(mood),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
