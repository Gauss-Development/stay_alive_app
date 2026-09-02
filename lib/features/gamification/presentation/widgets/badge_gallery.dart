import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/staggered_list.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_art.dart';

class BadgeGallery extends StatelessWidget {
  const BadgeGallery({required this.items, super.key});

  final List<BadgeGalleryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final BadgeGalleryItem item = items[index];
        final Widget tile = _BadgeGalleryTile(item: item, index: index);
        // Unlocked achievements pop in, locked ones just fade.
        return item.isUnlocked
            ? StaggeredScalePop(index: index, child: tile)
            : FadeSlideIn(
                delay: AppDurations.staggerStep * index.clamp(0, 12),
                offset: 0,
                child: tile,
              );
      },
    );
  }
}

class _BadgeGalleryTile extends StatelessWidget {
  const _BadgeGalleryTile({required this.item, required this.index});

  final BadgeGalleryItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool unlocked = item.isUnlocked;
    final Color tint =
        AppColors.badgeTints[index % AppColors.badgeTints.length];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: unlocked ? tint.withValues(alpha: 0.55) : context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BadgeArt(
            id: item.definition.id,
            fallbackEmoji: item.definition.emoji,
            size: 44,
            unlocked: unlocked,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            unlocked ? item.definition.name : context.l10n.badgeLocked,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelMedium?.copyWith(
              // Dark ink on the tint plate in both themes: the tint keeps
              // enough luminance under the dark background to carry it.
              color: unlocked
                  ? context.colors.onTertiary
                  : context.colors.onSurfaceVariant,
            ),
          ),
          if (item.earnedAt != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              DateFormat('d.MM').format(item.earnedAt!),
              // Only unlocked tiles carry a date, so this ink sits on the
              // tint plate too — the muted grey vanishes on it in dark mode.
              style: context.text.labelSmall?.copyWith(
                color: context.colors.onTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
