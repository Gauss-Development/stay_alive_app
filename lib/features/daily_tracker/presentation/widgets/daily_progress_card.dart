import 'package:flutter/material.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    required this.log,
    super.key,
  });

  final DailyLog log;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Today\'s progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${log.totalCompleted}/${log.totalTarget} completed',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: log.totalTarget == 0 ? 0 : log.totalCompleted / log.totalTarget,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
