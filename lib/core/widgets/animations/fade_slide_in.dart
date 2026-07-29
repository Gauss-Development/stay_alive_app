import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/widgets/animations/entrance_animation.dart';

/// One-shot entrance: fades in while sliding up from [offset] pixels.
///
/// Plays once when mounted (not on rebuilds). Honors reduced motion by
/// jumping straight to the end state.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.medium,
    this.curve = AppCurves.standard,
    this.offset = 16,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  /// Initial vertical offset in logical pixels.
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin, EntranceAnimation<FadeSlideIn> {
  late final Animation<double> _animation;

  @override
  Duration get entranceDelay => widget.delay;
  @override
  Duration get entranceDuration => widget.duration;

  @override
  void initState() {
    super.initState();
    initEntrance();
    _animation = CurvedAnimation(
      parent: entranceController,
      curve: Interval(intervalStart, 1, curve: widget.curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        final double t = _animation.value;
        return Opacity(
          opacity: t.clamp(0, 1),
          // Keep semantics during the brief entrance so screen readers and
          // hit targets are available immediately.
          alwaysIncludeSemantics: true,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
