import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_progress_bar.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';

class CategoryMasteryList extends StatelessWidget {
  const CategoryMasteryList({required this.items, super.key});

  final List<CategoryMastery> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'Отмечай продукты — и прокачивай категории.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        return _CategoryMasteryTile(mastery: items[index]);
      },
    );
  }
}

class _CategoryMasteryTile extends StatelessWidget {
  const _CategoryMasteryTile({required this.mastery});

  final CategoryMastery mastery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  mastery.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                ),
              ),
              _TierChip(tier: mastery.tier),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(value: mastery.progressToNextTier, height: 8),
          const SizedBox(height: 6),
          Text(
            mastery.tier == MasteryTier.platinum
                ? '${mastery.totalServings} порций отмечено'
                : '${mastery.totalServings}/${mastery.nextTierThreshold} '
                      'порций до следующего уровня',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({required this.tier});

  final MasteryTier tier;

  @override
  Widget build(BuildContext context) {
    if (tier == MasteryTier.none) {
      return const SizedBox.shrink();
    }

    final (String label, Color tint) = switch (tier) {
      MasteryTier.bronze => ('Бронза', AppColors.orange),
      MasteryTier.silver => ('Серебро', AppColors.blue),
      MasteryTier.gold => ('Золото', AppColors.softYellow),
      MasteryTier.platinum => ('Платина', AppColors.purple),
      MasteryTier.none => ('', AppColors.border),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
