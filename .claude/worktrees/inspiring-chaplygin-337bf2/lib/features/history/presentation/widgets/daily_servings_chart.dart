import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/features/history/domain/entities/daily_history_point.dart';

class DailyServingsChart extends StatelessWidget {
  const DailyServingsChart({
    required this.points,
    super.key,
  });

  final List<DailyHistoryPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final DateFormat labelFormat = DateFormat('d MMM');
    final int maxTarget = points
        .map((DailyHistoryPoint point) => point.totalTarget)
        .fold<int>(0, (int max, int value) => value > max ? value : max);
    final double maxY = maxTarget == 0 ? 24 : maxTarget.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Servings logged',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Completed servings vs daily target',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (double value) => FlLine(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: maxY / 4,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % (maxY / 4) != 0 && value != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final bool showLabel = points.length <= 7 ||
                              index == 0 ||
                              index == points.length - 1 ||
                              index % 5 == 0;
                          if (!showLabel) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labelFormat.format(points[index].date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          final int index = spot.x.toInt();
                          if (index < 0 || index >= points.length) {
                            return null;
                          }
                          final DailyHistoryPoint point = points[index];
                          return LineTooltipItem(
                            '${labelFormat.format(point.date)}\n'
                            '${point.totalCompleted}/${point.totalTarget} servings',
                            theme.textTheme.labelMedium!.copyWith(
                              color: colors.onInverseSurface,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: List<FlSpot>.generate(
                        points.length,
                        (int index) => FlSpot(
                          index.toDouble(),
                          points[index].totalCompleted.toDouble(),
                        ),
                      ),
                      isCurved: true,
                      color: colors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: points.length <= 14,
                        getDotPainter: (
                          FlSpot spot,
                          double percent,
                          LineChartBarData bar,
                          int index,
                        ) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: colors.primary,
                            strokeWidth: 1,
                            strokeColor: colors.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    LineChartBarData(
                      spots: List<FlSpot>.generate(
                        points.length,
                        (int index) => FlSpot(
                          index.toDouble(),
                          points[index].totalTarget.toDouble(),
                        ),
                      ),
                      isCurved: false,
                      color: colors.outline,
                      barWidth: 1.5,
                      dashArray: <int>[6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
