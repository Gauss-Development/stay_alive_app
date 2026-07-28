import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/motion/motion_config.dart';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final int total =
        widget.delay.inMilliseconds + widget.duration.inMilliseconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    final double start = total == 0 ? 0 : widget.delay.inMilliseconds / total;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: widget.curve),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MotionConfig.reduceMotionOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
