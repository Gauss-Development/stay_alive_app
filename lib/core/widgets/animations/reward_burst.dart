import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/widgets/animations/entrance_animation.dart';

/// One-shot radial burst of small dots — a short, premium reward accent
/// (used around the sprout when points appear, or inside a purchased card).
///
/// Plays once after [delay] and then stays invisible. Skipped entirely under
/// reduced motion.
class RewardBurst extends StatefulWidget {
  const RewardBurst({
    this.size = 180,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 850),
    this.colors = const <Color>[
      AppColors.lime,
      AppColors.softYellow,
      AppColors.mutedGreen,
      AppColors.blue,
    ],
    super.key,
  });

  final double size;
  final Duration delay;
  final Duration duration;
  final List<Color> colors;

  @override
  State<RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<RewardBurst>
    with SingleTickerProviderStateMixin, EntranceAnimation<RewardBurst> {
  late final Animation<double> _progress;
  late final List<_BurstDot> _dots;

  @override
  Duration get entranceDelay => widget.delay;
  @override
  Duration get entranceDuration => widget.duration;

  @override
  void initState() {
    super.initState();
    initEntrance();
    _progress = CurvedAnimation(
      parent: entranceController,
      curve: Interval(intervalStart, 1, curve: AppCurves.standard),
    );

    final math.Random rng = math.Random(3);
    _dots = List<_BurstDot>.generate(12, (int i) {
      final double angle = (i / 12) * math.pi * 2 + rng.nextDouble() * 0.4;
      return _BurstDot(
        angle: angle,
        distance: 0.6 + rng.nextDouble() * 0.4,
        size: 3 + rng.nextDouble() * 3.5,
        color: widget.colors[i % widget.colors.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BurstPainter(dots: _dots, progress: _progress),
          ),
        ),
      ),
    );
  }
}

class _BurstDot {
  const _BurstDot({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.dots, required this.progress})
    : super(repaint: progress);

  final List<_BurstDot> dots;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress.value;
    if (t <= 0 || t >= 1) {
      return;
    }

    final Offset center = size.center(Offset.zero);
    final double maxRadius = size.shortestSide / 2;
    final Paint paint = Paint();

    for (final _BurstDot dot in dots) {
      final double radius = maxRadius * dot.distance * t;
      final Offset position =
          center + Offset(math.cos(dot.angle), math.sin(dot.angle)) * radius;
      paint.color = dot.color.withValues(alpha: (1 - t).clamp(0, 1));
      canvas.drawCircle(position, dot.size * (1 - t * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.dots != dots;
}
