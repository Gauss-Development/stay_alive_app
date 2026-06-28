import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';

class BadgeGallery extends StatelessWidget {
  const BadgeGallery({
    required this.items,
    super.key,
  });

  final List<BadgeGalleryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _BadgeGalleryTile(item: items[index]);
      },
    );
  }
}

class _BadgeGalleryTile extends StatelessWidget {
  const _BadgeGalleryTile({required this.item});

  final BadgeGalleryItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool unlocked = item.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? colors.primaryContainer.withValues(alpha: 0.45)
            : colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            item.definition.emoji,
            style: TextStyle(
              fontSize: 28,
              color: unlocked ? null : colors.onSurface.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.definition.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.45),
            ),
          ),
          if (item.earnedAt != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d').format(item.earnedAt!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
