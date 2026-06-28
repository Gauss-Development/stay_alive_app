import 'package:flutter/material.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';

class HistoryStatsGrid extends StatelessWidget {
  const HistoryStatsGrid({
    required this.summary,
    super.key,
  });

  final HistorySummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= 560;
        final List<_StatCardData> cards = <_StatCardData>[
          _StatCardData(
            icon: Icons.calendar_month_outlined,
            label: 'Period average',
            value: '${summary.averageCompletionPercentage.toStringAsFixed(1)}%',
            subtitle:
                '${summary.completedDays}/${summary.totalDays} full days',
          ),
          _StatCardData(
            icon: Icons.local_fire_department_outlined,
            label: 'Current streak',
            value: '${summary.currentStreak}',
            subtitle: 'days in a row',
          ),
          _StatCardData(
            icon: Icons.emoji_events_outlined,
            label: 'Best streak',
            value: '${summary.bestStreak}',
            subtitle: 'longest run',
          ),
          _StatCardData(
            icon: Icons.trending_up,
            label: 'Last 7 days',
            value: '${summary.weeklyCompletionPercent.toStringAsFixed(1)}%',
            subtitle: 'weekly average',
          ),
        ];

        if (isWide) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: cards
                .map(
                  (_StatCardData card) => _HistoryStatCard(data: card),
                )
                .toList(growable: false),
          );
        }

        return Column(
          children: cards
              .map(
                (_StatCardData card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryStatCard(data: card),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
}

class _HistoryStatCard extends StatelessWidget {
  const _HistoryStatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.icon,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
