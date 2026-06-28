import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.challenge,
    super.key,
  });

  final GamificationChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool completed = challenge.isCompleted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  completed ? Icons.check_circle : Icons.flag_outlined,
                  color: completed ? colors.primary : colors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daily Challenge',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
              challenge.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: challenge.progressFraction,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              completed
                  ? 'Challenge complete!'
                  : '${challenge.progress}/${challenge.target} progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: completed ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
