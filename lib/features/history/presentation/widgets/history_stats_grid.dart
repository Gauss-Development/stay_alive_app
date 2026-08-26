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

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.45,
      children: cards
          .map((_StatCardData card) => _HistoryStatCard(data: card))
          .toList(growable: false),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.tint.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, size: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  data.label,
                  style: AppTextStyles.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.value,
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
              ),
              Text(
                data.subtitle,
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
