import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';

/// Circular progress ring (the dark "points" card on the home screen).
///
/// Renders an animated accent arc over a track ring with a centered [child].
class PointsRing extends StatelessWidget {
  const PointsRing({
    required this.fraction,
    this.accent = RostokColors.accent,
    this.trackColor = RostokColors.ringTrack,
    this.size = 104,
    this.thickness = 13,
    this.child,
    super.key,
  });

  /// 0.0–1.0 progress.
  final double fraction;
  final Color accent;
  final Color trackColor;
  final double size;
  final double thickness;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: fraction.clamp(0, 1)),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? _) {
          return CustomPaint(
            painter: _RingPainter(
              fraction: value,
              accent: accent,
              trackColor: trackColor,
              thickness: thickness,
            ),
            child: Center(child: child),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.accent,
    required this.trackColor,
    required this.thickness,
  });

  final double fraction;
  final Color accent;
  final Color trackColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - thickness) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, track);

    if (fraction > 0) {
      final Paint progress = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        progress,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.accent != accent ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.thickness != thickness;
  }
}
