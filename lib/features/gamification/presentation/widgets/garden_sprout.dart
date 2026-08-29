import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/widgets/sprout_image.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';

/// Live garden sprout driven by [GardenState] (scale + mood artwork).
///
/// The sprout never wilts or gets punished: an untouched day just makes it
/// look up expectantly (GAU-416). Mood comes from the domain
/// ([GardenState.mood]) so the face cannot change on an unrelated rebuild.
class GardenSprout extends StatelessWidget {
  const GardenSprout({
    required this.state,
    this.size = 96,
    this.showWiltingHint = true,
    super.key,
  });

  final GardenState state;
  final double size;
  final bool showWiltingHint;

  /// Visual boost over the layout box: the artwork paints larger than the
  /// reserved [size] (via [OverflowBox]) so the card never grows with it.
  static const double _visualBoost = 2.2;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: size,
          height: size,
          child: OverflowBox(
            maxWidth: size * _visualBoost * 1.2,
            maxHeight: size * _visualBoost * 1.2,
            child: AnimatedScale(
              scale: state.displayScale * _visualBoost,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              child: _BreathingSprout(
                mood: state.mood,
                // The boundary sits *inside* the transforms on purpose: the
                // artwork rasterises once and every animated frame only
                // re-composites that cached layer instead of repainting the
                // sprout (and, without it, the whole dark progress card).
                child: RepaintBoundary(
                  child: SproutImage(mood: state.mood, size: size),
                ),
              ),
            ),
          ),
        ),
        if (showWiltingHint && state.wilting) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Росток ждёт тебя сегодня',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Idle "breathing": a slow sine-ish scale that keeps the sprout alive.
///
/// Only a transform matrix changes per frame — no layout, no paint — so the
/// cost lands on the raster thread rather than the UI thread. The ticker is
/// dropped entirely when the platform asks for reduced motion, and it is
/// muted automatically while the widget sits in a disabled [TickerMode]
/// (hidden bottom-navigation tab).
class _BreathingSprout extends StatefulWidget {
  const _BreathingSprout({required this.mood, required this.child});

  final SproutMood mood;
  final Widget child;

  @override
  State<_BreathingSprout> createState() => _BreathingSproutState();
}

class _BreathingSproutState extends State<_BreathingSprout>
    with SingleTickerProviderStateMixin {
  /// Peak scale is +2.2% — visible as life, invisible as motion.
  static const double _amplitude = 0.022;
  static const Duration _awakePeriod = Duration(milliseconds: 2800);
  static const Duration _asleepPeriod = Duration(milliseconds: 4500);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _periodFor(widget.mood),
  );

  bool _reduceMotion = false;

  static Duration _periodFor(SproutMood mood) =>
      mood == SproutMood.sleeping ? _asleepPeriod : _awakePeriod;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MotionConfig.reduceMotionOf(context);
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _BreathingSprout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == oldWidget.mood) {
      return;
    }
    _controller.duration = _periodFor(widget.mood);
    if (_controller.isAnimating) {
      // `repeat` re-reads the duration; restart so the sleeping rhythm
      // actually slows down instead of finishing the old cycle.
      _controller
        ..stop()
        ..repeat(reverse: true);
    }
  }

  void _syncTicker() {
    if (_reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      // `child` is built once and handed back untouched: the per-frame
      // rebuild covers the transform wrapper only.
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double breath = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(
          scale: 1 + _amplitude * breath,
          child: child,
        );
      },
    );
  }
}
