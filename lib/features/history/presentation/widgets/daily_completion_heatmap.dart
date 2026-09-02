import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/features/history/domain/entities/daily_history_point.dart';

/// «Карта дней» — календарь текущего месяца в стиле Rostok: клетки дней
/// заливаются зелёным по мере приближения к цели, сегодня обведено,
/// будущее приглушено.
class DailyCompletionHeatmap extends StatelessWidget {
  const DailyCompletionHeatmap({required this.points, super.key});

  final List<DailyHistoryPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();
    // The grid is Monday-first, so the headers start from a known Monday
    // (2024-01-01) rather than from the locale's own first weekday.
    final DateFormat weekdayFormat = DateFormat.E(locale);
    final List<String> weekdays = List<String>.generate(
      7,
      (int i) => weekdayFormat.format(DateTime(2024, 1, 1 + i)).toUpperCase(),
      growable: false,
    );
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
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
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
                context.l10n.historyHeatmapTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                DateFormat.yMMMM(locale).format(anchor),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: weekdays
                .map(
                  (String day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        // labelSmall already carries the muted ink.
                        style: theme.textTheme.labelSmall?.copyWith(
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
                  isToday:
                      today.year == anchor.year &&
                      today.month == anchor.month &&
                      today.day == day,
                  isFuture: DateTime(
                    anchor.year,
                    anchor.month,
                    day,
                  ).isAfter(DateTime(today.year, today.month, today.day)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              _LegendItem(
                color: AppColors.green,
                label: context.l10n.historyLegendGoalMet,
              ),
              _LegendItem(
                color: AppColors.mutedGreen,
                label: context.l10n.historyLegendPartial,
              ),
              _LegendItem(
                color: theme.scaffoldBackgroundColor,
                label: context.l10n.historyLegendNoEntry,
              ),
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

    final ThemeData theme = Theme.of(context);
    // The muted ink only surfaces through labelSmall — ColorScheme has no
    // role for it.
    final Color mutedInk =
        theme.textTheme.labelSmall?.color ?? theme.colorScheme.onSurfaceVariant;

    final Color background;
    final Color textColor;
    if (isFuture) {
      background = Colors.transparent;
      textColor = mutedInk.withValues(alpha: 0.45);
    } else if (completed) {
      background = AppColors.green;
      textColor = AppColors.white;
    } else if (fraction > 0) {
      background =
          Color.lerp(AppColors.mutedGreen, AppColors.green, fraction) ??
          AppColors.mutedGreen;
      // The fill is the same pastel in both themes, so the ink stays dark.
      textColor = fraction > 0.6 ? AppColors.white : AppColors.textPrimary;
    } else {
      // Empty day: the page tone, a shade off the card in both themes.
      background = theme.scaffoldBackgroundColor;
      textColor = mutedInk;
    }

    final Widget cell = Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: isToday
            ? Border.all(color: theme.colorScheme.onSurface, width: 1.5)
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
      message: context.l10n.historyHeatmapTooltip(
        DateFormat.yMMMd(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(date),
        data.totalCompleted,
        data.totalTarget,
        data.completionPercentage.toStringAsFixed(0),
      ),
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
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
