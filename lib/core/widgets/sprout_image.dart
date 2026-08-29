import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';

export 'package:stay_alive/features/gamification/domain/entities/garden_state.dart'
    show SproutMood;

/// Maps a domain [SproutMood] onto the bundled artwork
/// (`assets/sprout/`, 1x/2x/3x densities).
///
/// Artwork file names predate the domain vocabulary: `curious` is the
/// `waiting` face, `cheer` is the celebration/reunion one.
extension SproutMoodAsset on SproutMood {
  String get assetPath => switch (this) {
        SproutMood.happy => 'assets/sprout/sprout_happy.png',
        SproutMood.waiting => 'assets/sprout/sprout_curious.png',
        SproutMood.sleeping => 'assets/sprout/sprout_sleep.png',
        SproutMood.celebrating => 'assets/sprout/sprout_cheer.png',
      };
}

/// Renders the sprout in the given [mood] with a soft cross-fade on change.
class SproutImage extends StatefulWidget {
  const SproutImage({
    required this.mood,
    this.size = 96,
    super.key,
  });

  final SproutMood mood;
  final double size;

  @override
  State<SproutImage> createState() => _SproutImageState();
}

class _SproutImageState extends State<SproutImage> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) {
      return;
    }
    _precached = true;
    // Decode every mood up front: the cross-fade starts the moment the mood
    // changes, and an undecoded asset would fade in from nothing.
    for (final SproutMood mood in SproutMood.values) {
      unawaited(precacheImage(AssetImage(mood.assetPath), context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Image.asset(
        widget.mood.assetPath,
        key: ValueKey<SproutMood>(widget.mood),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
