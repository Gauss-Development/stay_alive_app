import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';

class BadgeList extends StatelessWidget {
  const BadgeList({required this.badges, super.key});

  final List<EarnedBadge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'Пока нет наград — всё впереди!',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        return _BadgeTile(badge: badges[index], index: index);
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.index});

  final EarnedBadge badge;
  final int index;

  @override
  Widget build(BuildContext context) {
    final def = badge.definition;
    final String dateStr = DateFormat('d.MM.yyyy').format(badge.earnedAt);
    final Color tint =
        AppColors.badgeTints[index % AppColors.badgeTints.length];

    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Text(def.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                def.name,
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                def.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(dateStr, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
