import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/features/history/domain/entities/daily_history_point.dart';

class DailyCompletionHeatmap extends StatelessWidget {
  const DailyCompletionHeatmap({required this.points, super.key});

  final List<DailyHistoryPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Карта дней',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Каждая клетка — насколько день был близок к цели',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: points
                  .map((DailyHistoryPoint point) {
                    return _HeatmapCell(point: point);
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                const _LegendItem(
                  color: AppColors.green,
                  label: 'Цель выполнена',
                ),
                const _LegendItem(color: AppColors.lime, label: 'В процессе'),
                _LegendItem(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                  label: 'Нет записи',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.point});

  final DailyHistoryPoint point;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color backgroundColor = !point.hasLog
        ? colors.outlineVariant.withValues(alpha: 0.25)
        : point.isFullyCompleted
        ? AppColors.green
        : Color.lerp(
                AppColors.lime.withValues(alpha: 0.25),
                AppColors.lime,
                (point.completionPercentage / 100).clamp(0, 1),
              ) ??
              AppColors.lime;

    return Tooltip(
      message:
          '${point.dateKey}: '
          '${point.totalCompleted}/${point.totalTarget} порций '
          '(${point.completionPercentage.toStringAsFixed(0)}%)',
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '${point.date.day}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: point.isFullyCompleted
                ? AppColors.white
                : colors.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
