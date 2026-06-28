import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_list.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/streak_chip.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/xp_level_bar.dart';

class GamificationProgressCard extends StatelessWidget {
  const GamificationProgressCard({
    required this.profile,
    super.key,
  });

  final UserGameProfile profile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.emoji_events_outlined,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                StreakChip(
                  streak: profile.currentStreak,
                  style: StreakChipStyle.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            XpLevelBar(profile: profile),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StatChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Perfect streak',
                  value: '${profile.currentStreak}',
                ),
                _StatChip(
                  icon: Icons.bolt_outlined,
                  label: 'Active streak',
                  value: '${profile.activityStreak}',
                ),
                _StatChip(
                  icon: Icons.emoji_events_outlined,
                  label: 'Best streak',
                  value: '${profile.longestStreak}',
                ),
                _StatChip(
                  icon: Icons.check_circle_outline,
                  label: 'Perfect days',
                  value: '${profile.completedDates.length}',
                ),
              ],
            ),
            if (profile.earnedBadges.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Badges',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              BadgeList(badges: profile.earnedBadges),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push(AppRoutes.progress),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('View full progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
