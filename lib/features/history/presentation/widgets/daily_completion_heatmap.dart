import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/features/history/domain/entities/daily_history_point.dart';

/// «Карта дней» — календарь текущего месяца в стиле Rostok: клетки дней
/// заливаются зелёным по мере приближения к цели, сегодня обведено,
/// будущее приглушено.
class DailyCompletionHeatmap extends StatelessWidget {
  const DailyCompletionHeatmap({required this.points, super.key});

  final List<DailyHistoryPoint> points;

  static const List<String> _weekdays = <String>[
    'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС',
  ];

  static const List<String> _months = <String>[
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final DateTime today = DateTime.now();
    // Календарь показывает месяц самой свежей точки (обычно текущий).
    final DateTime anchor = points.last.date;
    final DateTime firstDay = DateTime(anchor.year, anchor.month);
    final int daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
    final int leadingBlanks = firstDay.weekday - 1; // Пн = 0 пустых

    final Map<String, DailyHistoryPoint> byDateKey =
        <String, DailyHistoryPoint>{
      for (final DailyHistoryPoint point in points) point.dateKey: point,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                'Карта дней',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_months[anchor.month - 1]} ${anchor.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: _weekdays
                .map(
                  (String day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: <Widget>[
              for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (int day = 1; day <= daysInMonth; day++)
                _DayCell(
                  date: DateTime(anchor.year, anchor.month, day),
                  point: byDateKey[_dateKey(anchor.year, anchor.month, day)],
                  isToday: today.year == anchor.year &&
                      today.month == anchor.month &&
                      today.day == day,
                  isFuture: DateTime(anchor.year, anchor.month, day)
                      .isAfter(DateTime(today.year, today.month, today.day)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: const <Widget>[
              _LegendItem(color: AppColors.green, label: 'Цель выполнена'),
              _LegendItem(color: AppColors.mutedGreen, label: 'Частично'),
              _LegendItem(color: AppColors.background, label: 'Нет записи'),
            ],
          ),
        ],
      ),
    );
  }

  static String _dateKey(int year, int month, int day) {
    final String m = month.toString().padLeft(2, '0');
    final String d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.point,
    required this.isToday,
    required this.isFuture,
  });

  final DateTime date;
  final DailyHistoryPoint? point;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final double fraction = point == null || !point!.hasLog
        ? 0
        : (point!.completionPercentage / 100).clamp(0.0, 1.0);
    final bool completed = point?.isFullyCompleted ?? false;

    final Color background;
    final Color textColor;
    if (isFuture) {
      background = Colors.transparent;
      textColor = AppColors.textMuted.withValues(alpha: 0.45);
    } else if (completed) {
      background = AppColors.green;
      textColor = AppColors.white;
    } else if (fraction > 0) {
      background =
          Color.lerp(AppColors.mutedGreen, AppColors.green, fraction) ??
              AppColors.mutedGreen;
      textColor = fraction > 0.6 ? AppColors.white : AppColors.textPrimary;
    } else {
      background = AppColors.background;
      textColor = AppColors.textMuted;
    }

    final Widget cell = Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: isToday
            ? Border.all(color: AppColors.dark, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    final DailyHistoryPoint? data = point;
    if (data == null || !data.hasLog || isFuture) {
      return cell;
    }
    return Tooltip(
      message: '${data.dateKey}: ${data.totalCompleted}/${data.totalTarget} '
          'порций (${data.completionPercentage.toStringAsFixed(0)}%)',
      child: cell,
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
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
