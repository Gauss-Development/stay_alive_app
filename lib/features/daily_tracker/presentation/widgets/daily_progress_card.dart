import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/animated_points_counter.dart';
import 'package:stay_alive/core/widgets/app_badge.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';

/// Dark hero card of the home screen: daily ring, level and remaining goal.
class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    required this.log,
    this.level,
    this.levelTitle,
    this.streak,
    super.key,
  });

  final DailyLog log;
  final int? level;
  final String? levelTitle;
  final int? streak;

  @override
  Widget build(BuildContext context) {
    final int done = log.totalCompleted;
    final int goal = log.totalTarget;
    final int remaining = (goal - done).clamp(0, goal);
    final double fraction = goal > 0 ? (done / goal).clamp(0.0, 1.0) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: <Widget>[
          _ProgressRing(
            fraction: fraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedPointsCounter(
                  value: done,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                    height: 1,
                  ),
                ),
                Text(
                  'из $goal',
                  style: AppTextStyles.labelSmall.copyWith(height: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (level != null)
                  AppBadge(
                    label: 'Уровень $level · ${levelTitle ?? ''}',
                    onDark: true,
                  ),
                const SizedBox(height: AppSpacing.md),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      height: 1.3,
                    ),
                    children: <InlineSpan>[
                      const TextSpan(text: 'Осталось '),
                      TextSpan(
                        text: '$remaining',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.lime,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: remaining == 0
                            ? ' — цель дня выполнена!'
                            : ' порций до цели дня',
                      ),
                    ],
                  ),
                ),
                if (streak != null && streak! > 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '🔥 $streak дней подряд',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.fraction, this.child});

  final double fraction;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: fraction),
        duration: AppDurations.slow,
        curve: AppCurves.standard,
        builder: (BuildContext context, double value, Widget? _) {
          return CustomPaint(
            painter: _RingPainter(fraction: value),
            child: Center(child: child),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  static const double _thickness = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - _thickness) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.darkChip
        ..style = PaintingStyle.stroke
        ..strokeWidth = _thickness,
    );

    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        Paint()
          ..color = AppColors.lime
          ..style = PaintingStyle.stroke
          ..strokeWidth = _thickness
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
