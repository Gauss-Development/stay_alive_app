import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// The signature «росток» growth animation: a seed appears, the stem grows
/// upward, then two soft leaves unfold.
///
/// Simple app-like symbol (not botanical), drawn with a [CustomPainter].
/// Plays once on mount; shows the fully grown sprout under reduced motion.
class SproutGrowthAnimation extends StatefulWidget {
  const SproutGrowthAnimation({
    this.size = 64,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.stemColor = AppColors.green,
    this.leafColor = AppColors.lime,
    super.key,
  });

  final double size;
  final Duration delay;
  final Duration duration;
  final Color stemColor;
  final Color leafColor;

  @override
  State<SproutGrowthAnimation> createState() => _SproutGrowthAnimationState();
}

class _SproutGrowthAnimationState extends State<SproutGrowthAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
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
    _progress = CurvedAnimation(
      parent: _controller,
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
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _SproutPainter(
            progress: _progress,
            stemColor: widget.stemColor,
            leafColor: widget.leafColor,
          ),
        ),
      ),
    );
  }
}

class _SproutPainter extends CustomPainter {
  _SproutPainter({
    required this.progress,
    required this.stemColor,
    required this.leafColor,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color stemColor;
  final Color leafColor;

  static double _phase(double t, double from, double to) {
    if (to <= from) {
      return 1;
    }
    return ((t - from) / (to - from)).clamp(0, 1).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress.value;
    if (t <= 0) {
      return;
    }

    final double w = size.width;
    final double h = size.height;
    final Offset seedCenter = Offset(w * 0.5, h * 0.88);

    // 1) Seed pops in.
    final double seed = Curves.easeOutBack.transform(_phase(t, 0, 0.18));
    if (seed > 0) {
      canvas.drawCircle(
        seedCenter,
        w * 0.075 * seed,
        Paint()..color = stemColor,
      );
    }

    // 2) Stem grows upward with a gentle curve.
    final double stem = _phase(t, 0.12, 0.58);
    final Offset stemTop = Offset(w * 0.52, h * 0.28);
    if (stem > 0) {
      final Path fullStem = Path()
        ..moveTo(seedCenter.dx, seedCenter.dy)
        ..quadraticBezierTo(w * 0.42, h * 0.58, stemTop.dx, stemTop.dy);
      final PathMetric metric = fullStem.computeMetrics().first;
      final Path grown = metric.extractPath(0, metric.length * stem);
      canvas.drawPath(
        grown,
        Paint()
          ..color = stemColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.075
          ..strokeCap = StrokeCap.round,
      );
    }

    // 3) Two leaves unfold at the stem top.
    _drawLeaf(
      canvas,
      size,
      origin: stemTop,
      angle: -math.pi * 0.42,
      unfold: Curves.easeOutBack.transform(_phase(t, 0.5, 0.82)),
      color: leafColor,
    );
    _drawLeaf(
      canvas,
      size,
      origin: stemTop,
      angle: math.pi * 0.12,
      unfold: Curves.easeOutBack.transform(_phase(t, 0.62, 0.96)),
      color: stemColor,
    );
  }

  void _drawLeaf(
    Canvas canvas,
    Size size, {
    required Offset origin,
    required double angle,
    required double unfold,
    required Color color,
  }) {
    if (unfold <= 0) {
      return;
    }
    final double leafLength = size.width * 0.34 * unfold;
    final double leafWidth = size.width * 0.2 * unfold;

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final RRect leaf = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, -leafWidth / 2, leafLength, leafWidth),
      topLeft: Radius.circular(leafWidth * 0.2),
      topRight: Radius.circular(leafWidth),
      bottomRight: Radius.circular(leafWidth),
      bottomLeft: Radius.circular(leafWidth),
    );
    canvas.drawRRect(leaf, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SproutPainter oldDelegate) =>
      oldDelegate.stemColor != stemColor || oldDelegate.leafColor != leafColor;
}
