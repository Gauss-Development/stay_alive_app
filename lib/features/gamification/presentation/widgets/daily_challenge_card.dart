import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/app_badge.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/core/widgets/app_progress_bar.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';

/// Quest-style challenge card. Weekly challenges get the dark hero look,
/// daily ones a light card.
class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.challenge,
    this.isPremium = true,
    super.key,
  });

  final GamificationChallenge challenge;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final bool locked = challenge.isPremiumOnly && !isPremium;
    final bool completed = challenge.isCompleted && !locked;
    final bool isWeekly = challenge.period == ChallengePeriod.weekly;

    if (isWeekly) {
      return _CompletionPulse(
        completed: completed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: _WeeklyHeroCard(
          challenge: challenge,
          locked: locked,
          completed: completed,
        ),
      );
    }

    return _CompletionPulse(
      completed: completed,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AppCard(
        radius: AppRadius.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AppBadge(
                    label: locked ? 'Квест · Premium' : 'Квест дня',
                    accent: completed ? AppColors.green : AppColors.lime,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                BadgePop(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    '+${challenge.xpReward}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              challenge.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              locked
                  ? 'Открой Premium, чтобы получать бонусные очки за этот квест.'
                  : challenge.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppProgressBar(
                    value: locked ? 0 : challenge.progressFraction,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  locked
                      ? '—'
                      : completed
                      ? 'Готово!'
                      : '${challenge.progress}/${challenge.target}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: completed ? AppColors.green : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One-shot lime highlight pulse when a challenge flips to completed.
class _CompletionPulse extends StatefulWidget {
  const _CompletionPulse({
    required this.completed,
    required this.borderRadius,
    required this.child,
  });

  final bool completed;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  State<_CompletionPulse> createState() => _CompletionPulseState();
}

class _CompletionPulseState extends State<_CompletionPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  @override
  void didUpdateWidget(_CompletionPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed &&
        !oldWidget.completed &&
        !MotionConfig.reduceMotionOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? _) {
                final double t = _controller.value;
                if (t <= 0 || t >= 1) {
                  return const SizedBox.shrink();
                }
                // Fades in and out over the pulse.
                final double opacity = math.sin(t * math.pi);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: Border.all(
                      color: AppColors.lime.withValues(alpha: opacity),
                      width: 2.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyHeroCard extends StatelessWidget {
  const _WeeklyHeroCard({
    required this.challenge,
    required this.locked,
    required this.completed,
  });

  final GamificationChallenge challenge;
  final bool locked;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const AppBadge(label: 'ЧЕЛЛЕНДЖ НЕДЕЛИ', onDark: true),
                const SizedBox(height: AppSpacing.md),
                Text(
                  challenge.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  locked
                      ? 'Открой Premium, чтобы участвовать в недельном челлендже.'
                      : challenge.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      locked
                          ? 'Premium'
                          : completed
                          ? 'Выполнено!'
                          : '${challenge.progress} из ${challenge.target}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    BadgePop(
                      delay: const Duration(milliseconds: 250),
                      child: Text(
                        '+${challenge.xpReward} очков',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.lime,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppProgressBar(
                  value: locked ? 0 : challenge.progressFraction,
                  backgroundColor: AppColors.darkChip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
