import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/motion/motion_config.dart';

/// One-shot pop entrance: scales from [fromScale] with a soft overshoot
/// while fading in. For sprouts, avatars, badges and small accents.
class ScalePop extends StatefulWidget {
  const ScalePop({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 320),
    this.curve = AppCurves.emphasized,
    this.fromScale = 0.92,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double fromScale;

  @override
  State<ScalePop> createState() => _ScalePopState();
}

class _ScalePopState extends State<ScalePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
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
    _scale = Tween<double>(begin: widget.fromScale, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, 1, curve: widget.curve),
      ),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      // Opacity uses a plain curve so easeOutBack overshoot never pushes
      // opacity outside 0..1.
      curve: Interval(start, 1, curve: AppCurves.standard),
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
    return FadeTransition(
      opacity: _opacity,
      // Keep semantics during the brief entrance.
      alwaysIncludeSemantics: true,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Convenience: [ScalePop] used purely for micro badges with the token
/// durations already applied.
class BadgePop extends StatelessWidget {
  const BadgePop({required this.child, this.delay = Duration.zero, super.key});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return ScalePop(delay: delay, duration: AppDurations.medium, child: child);
  }
}
