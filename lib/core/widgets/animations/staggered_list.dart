import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';

/// Fade-slide entrance staggered by list [index].
///
/// The delay is capped so long lists never feel slow: items beyond
/// [maxStaggeredItems] all animate together.
class StaggeredFadeSlide extends StatelessWidget {
  const StaggeredFadeSlide({
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.step = AppDurations.staggerStep,
    this.maxStaggeredItems = 8,
    super.key,
  });

  final int index;
  final Widget child;

  /// Extra delay applied before the whole stagger starts.
  final Duration baseDelay;
  final Duration step;
  final int maxStaggeredItems;

  @override
  Widget build(BuildContext context) {
    final int effectiveIndex = index.clamp(0, maxStaggeredItems);
    return FadeSlideIn(delay: baseDelay + step * effectiveIndex, child: child);
  }
}

/// Scale-pop entrance staggered by [index] — for badge/achievement grids.
class StaggeredScalePop extends StatelessWidget {
  const StaggeredScalePop({
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.step = AppDurations.staggerStep,
    this.maxStaggeredItems = 12,
    super.key,
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration step;
  final int maxStaggeredItems;

  @override
  Widget build(BuildContext context) {
    final int effectiveIndex = index.clamp(0, maxStaggeredItems);
    return ScalePop(delay: baseDelay + step * effectiveIndex, child: child);
  }
}
