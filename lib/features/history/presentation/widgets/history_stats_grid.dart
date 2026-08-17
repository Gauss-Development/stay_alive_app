import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';

class HistoryStatsGrid extends StatelessWidget {
  const HistoryStatsGrid({required this.summary, super.key});

  final HistorySummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= 560;
        final List<_StatCardData> cards = <_StatCardData>[
          _StatCardData(
            icon: Icons.calendar_month_outlined,
            tint: AppColors.mutedGreen,
            label: 'Среднее за период',
            value: '${summary.averageCompletionPercentage.toStringAsFixed(1)}%',
            subtitle:
                '${summary.completedDays}/${summary.totalDays} '
                'полных дней',
          ),
          _StatCardData(
            icon: Icons.local_fire_department_outlined,
            tint: AppColors.softYellow,
            label: 'Текущая серия',
            value: '${summary.currentStreak}',
            subtitle: 'дней подряд',
          ),
          _StatCardData(
            icon: Icons.emoji_events_outlined,
            tint: AppColors.purple,
            label: 'Рекорд',
            value: '${summary.bestStreak}',
            subtitle: 'лучшая серия',
          ),
          _StatCardData(
            icon: Icons.trending_up_rounded,
            tint: AppColors.blue,
            label: 'Последние 7 дней',
            value: '${summary.weeklyCompletionPercent.toStringAsFixed(1)}%',
            subtitle: 'среднее за неделю',
          ),
        ];

        if (isWide) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.2,
            children: cards
                .map((_StatCardData card) => _HistoryStatCard(data: card))
                .toList(growable: false),
          );
        }

        return Column(
          children: cards
              .map(
                (_StatCardData card) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
    required this.tint,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final String subtitle;
}

class _HistoryStatCard extends StatelessWidget {
  const _HistoryStatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.tint.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(data.label, style: AppTextStyles.labelMedium),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
                ),
                Text(data.subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
