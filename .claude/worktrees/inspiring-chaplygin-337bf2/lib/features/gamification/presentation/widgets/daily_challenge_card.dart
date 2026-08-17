import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool locked = challenge.isPremiumOnly && !isPremium;
    final bool completed = challenge.isCompleted && !locked;
    final String periodLabel = switch (challenge.period) {
      ChallengePeriod.daily => 'Daily Challenge',
      ChallengePeriod.weekly => 'Weekly Challenge',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  locked
                      ? Icons.lock_outline
                      : completed
                          ? Icons.check_circle
                          : Icons.flag_outlined,
                  color: locked
                      ? colors.onSurfaceVariant
                      : completed
                          ? colors.primary
                          : colors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    periodLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (challenge.isPremiumOnly)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.workspace_premium_outlined,
                      size: 18,
                      color: colors.tertiary,
                    ),
                  ),
                Text(
                  '+${challenge.xpReward} XP',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              locked
                  ? 'Unlock with Premium to earn bonus XP from this challenge.'
                  : challenge.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: locked ? 0 : challenge.progressFraction,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              locked
                  ? 'Premium perk'
                  : completed
                      ? 'Challenge complete!'
                      : '${challenge.progress}/${challenge.target} progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: completed || locked
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
