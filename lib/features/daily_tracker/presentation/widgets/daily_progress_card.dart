import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/animated_points_counter.dart';
import 'package:stay_alive/core/widgets/app_badge.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/garden_sprout.dart';

/// Dark hero card of the home screen: garden sprout, daily ring, level and remaining goal.
class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    required this.log,
    this.level,
    this.levelTitle,
    this.streak,
    this.garden,
    super.key,
  });

  final DailyLog log;
  final int? level;
  final String? levelTitle;
  final int? streak;
  final GardenState? garden;

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
      child: Column(
        children: <Widget>[
          if (garden != null) ...<Widget>[
            GardenSprout(
              state: garden!,
              size: 88,
              showWiltingHint: garden!.wilting,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: <Widget>[
              _ProgressRing(
                fraction: fraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedPointsCounter(
                      value: done,
                      style: context.text.headlineMedium?.copyWith(
                        color: AppColors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      context.l10n.homeProgressOfGoal(goal),
                      style: context.text.labelSmall?.copyWith(
                        // Pinned: the card is dark in both themes, so the ink
                        // must not follow the theme.
                        color: AppColors.textMuted,
                        height: 1.1,
                      ),
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
                        label: context.l10n.homeLevelBadge(
                          level!,
                          levelTitle ?? '',
                        ),
                        onDark: true,
                      ),
                    const SizedBox(height: AppSpacing.md),
                    _remainingText(context, remaining),
                    if (streak != null && streak! > 0) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.l10n.homeStreakDays(streak!),
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The remaining-servings line, with the count highlighted in lime.
  ///
  /// Word order differs per language, so the sentence comes from one ICU
  /// message and the count is re-styled by locating it in the result.
  // ponytail: highlights the first occurrence of the digits; fine because the
  // count is the only number in every translation of this message.
  static Widget _remainingText(BuildContext context, int remaining) {
    final String text = remaining == 0
        ? context.l10n.homeGoalReached
        : context.l10n.homeRemainingServings(remaining);
    final TextStyle base = (context.text.bodyLarge ?? const TextStyle())
        .copyWith(color: AppColors.white, height: 1.3);
    final String number = '$remaining';
    final int start = text.indexOf(number);
    if (start < 0) {
      return Text(text, style: base);
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: number,
            style: base.copyWith(
              color: AppColors.lime,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(start + number.length)),
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
