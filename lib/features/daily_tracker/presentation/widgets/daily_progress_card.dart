import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({required this.log, super.key});

  final DailyLog log;

  @override
  Widget build(BuildContext context) {
    final double progress = log.totalTarget == 0
        ? 0.0
        : (log.totalCompleted / log.totalTarget).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? _) {
        return SizedBox(
          width: 190,
          height: 190,
          child: CustomPaint(
            painter: _RingPainter(progress: value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${log.totalCompleted} of ${log.totalTarget}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'DAILY DOZEN',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 14;
    const double strokeWidth = 14.0;
    const double startAngle = -math.pi / 2;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0.01) return;

    final double sweepAngle = 2 * math.pi * progress;

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFF8CBF93)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Glowing tip dot
    final double endAngle = startAngle + sweepAngle;
    final double tipX = center.dx + radius * math.cos(endAngle);
    final double tipY = center.dy + radius * math.sin(endAngle);

    canvas.drawCircle(
      Offset(tipX, tipY),
      10,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
