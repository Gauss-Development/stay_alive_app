import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';

class CategoryMasteryList extends StatelessWidget {
  const CategoryMasteryList({
    required this.items,
    super.key,
  });

  final List<CategoryMastery> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Start logging servings to build category mastery.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  mastery.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _TierChip(tier: mastery.tier),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: mastery.progressToNextTier,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mastery.tier == MasteryTier.platinum
                ? '${mastery.totalServings} servings logged'
                : '${mastery.totalServings}/${mastery.nextTierThreshold} servings to next tier',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
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

    final String label = switch (tier) {
      MasteryTier.bronze => 'Bronze',
      MasteryTier.silver => 'Silver',
      MasteryTier.gold => 'Gold',
      MasteryTier.platinum => 'Platinum',
      MasteryTier.none => '',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
