import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_badge.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_list.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/streak_chip.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/xp_level_bar.dart';

/// Progress summary card: level bar, streak stats and recent badges.
class GamificationProgressCard extends StatelessWidget {
  const GamificationProgressCard({
    required this.profile,
    this.isPremium = false,
    this.xpMultiplier = 1,
    super.key,
  });

  final UserGameProfile profile;
  final bool isPremium;
  final double xpMultiplier;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('Твой прогресс', style: AppTextStyles.titleMedium),
              ),
              StreakChip(
                streak: profile.currentStreak,
                style: StreakChipStyle.compact,
              ),
            ],
          ),
          if (isPremium) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AppBadge(
              label: 'Premium · ${xpMultiplier}x очков',
              accent: AppColors.orange,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          XpLevelBar(profile: profile),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _StatChip(
                label: 'Идеальная серия',
                value: '${profile.currentStreak}',
              ),
              _StatChip(
                label: 'Активная серия',
                value: '${profile.activityStreak}',
              ),
              _StatChip(label: 'Рекорд', value: '${profile.longestStreak}'),
              _StatChip(
                label: 'Идеальные дни',
                value: '${profile.completedDates.length}',
              ),
              _StatChip(
                label: 'Заморозки',
                value: '${profile.streakFreezesRemaining}',
              ),
            ],
          ),
          if (profile.earnedBadges.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text('Награды', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            BadgeList(badges: profile.earnedBadges),
          ],
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.progress),
              child: Text(
                'Все челленджи →',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value, style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
