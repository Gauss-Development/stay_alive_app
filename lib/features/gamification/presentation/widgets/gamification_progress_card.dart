import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';

class GamificationProgressCard extends StatelessWidget {
  const GamificationProgressCard({
    required this.progress,
    super.key,
  });

  final GamificationProgress progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int xpIntoLevel = progress.xp % 100;
    final double levelProgress = xpIntoLevel / 100;

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
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Level ${progress.level}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text('${progress.xp} XP'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: levelProgress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.nextLevelXp - progress.xp} XP to next level',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text('🔥 ${progress.currentStreak} day streak')),
                Chip(label: Text('🏆 Best ${progress.bestStreak}')),
                Chip(label: Text('✅ ${progress.completedDays} perfect days')),
              ],
            ),
            if (progress.badges.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: progress.badges
                    .map(
                      (String badge) => InputChip(
                        avatar: const Icon(Icons.workspace_premium, size: 18),
                        label: Text(_formatBadge(badge)),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBadge(String badge) {
    return badge
        .split('_')
        .map(
          (String word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
