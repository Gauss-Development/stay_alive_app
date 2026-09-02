import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stay_alive/core/constants/category_assets.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/widgets/animations/animated_check_button.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

/// White rounded row for a Daily-Dozen category with serving controls.
class CategoryProgressTile extends StatelessWidget {
  const CategoryProgressTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    this.tintIndex = 0,
    super.key,
  });

  final DailyLogItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// Index used to pick a soft icon tint from [AppColors.foodTints].
  final int tintIndex;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = item.isCompleted;
    final ThemeData theme = Theme.of(context);
    // The muted ink only surfaces through labelSmall — ColorScheme has no
    // role for it.
    final Color? mutedInk = theme.textTheme.labelSmall?.color;

    return PressableScale(
      pressedScale: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              _CategoryIcon(
                iconKey: item.category.iconKey,
                isCompleted: isCompleted,
                tint:
                    AppColors.foodTints[tintIndex % AppColors.foodTints.length],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        // null keeps bodyLarge's own primary ink.
                        color: isCompleted ? mutedInk : null,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: mutedInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CategoryProgress(
                      completed: item.completedCount,
                      total: item.targetCount,
                      isCompleted: isCompleted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TileControls(
                completedCount: item.completedCount,
                isCompleted: isCompleted,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                categoryTitle: item.title,
                totalTarget: item.targetCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.iconKey,
    required this.isCompleted,
    required this.tint,
  });

  final String iconKey;
  final bool isCompleted;
  final Color tint;

  static const Map<String, IconData> _icons = <String, IconData>{
    'beans': Icons.grain_rounded,
    'berries': Icons.spa_rounded,
    'fruits': Icons.eco_rounded,
    'cruciferous': Icons.grass_rounded,
    'cruciferous_vegetables': Icons.grass_rounded,
    'greens': Icons.park_rounded,
    'vegetables': Icons.local_florist_rounded,
    'other_vegetables': Icons.local_florist_rounded,
    'flaxseeds': Icons.scatter_plot_rounded,
    'nuts': Icons.circle_outlined,
    'spices': Icons.kitchen_rounded,
    'whole_grains': Icons.breakfast_dining_rounded,
    'beverages': Icons.water_drop_rounded,
    'exercise': Icons.directions_run_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final String? assetPath = CategoryAssets.pathFor(iconKey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: assetPath != null
            ? AppColors.white
            : (isCompleted ? AppColors.mutedGreen : tint),
        shape: BoxShape.circle,
        border: assetPath != null
            ? Border.all(
                color: isCompleted ? AppColors.mutedGreen : tint,
                width: 2,
              )
            : null,
      ),
      child: assetPath != null
          ? _CategoryAssetIcon(assetPath: assetPath, isCompleted: isCompleted)
          : Icon(
              _icons[iconKey.toLowerCase()] ?? Icons.eco_rounded,
              color: AppColors.textPrimary.withValues(
                alpha: isCompleted ? 0.7 : 0.55,
              ),
              size: 20,
            ),
    );
  }
}

class _CategoryAssetIcon extends StatelessWidget {
  const _CategoryAssetIcon({
    required this.assetPath,
    required this.isCompleted,
  });

  final String assetPath;
  final bool isCompleted;

  static const double _imageSize = 34;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      assetPath,
      width: _imageSize,
      height: _imageSize,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    return Center(
      child: isCompleted ? Opacity(opacity: 0.45, child: image) : image,
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  const _CategoryProgress({
    required this.completed,
    required this.total,
    required this.isCompleted,
  });

  final int completed;
  final int total;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? labelColor = isCompleted
        ? AppColors.green
        : theme.textTheme.labelSmall?.color;

    if (total <= 1) {
      return Text(
        isCompleted
            ? context.l10n.homeTileDone
            : context.l10n.homeTileTapToMark,
        style: theme.textTheme.labelMedium?.copyWith(color: labelColor),
      );
    }

    if (total <= 8) {
      return Row(
        children: List<Widget>.generate(total, (int i) {
          final bool filled = i < completed;
          return Padding(
            padding: const EdgeInsets.only(right: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: filled ? 10 : 8,
              height: filled ? 10 : 8,
              decoration: BoxDecoration(
                color: filled
                    ? AppColors.lime
                    : theme.colorScheme.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      );
    }

    return Text(
      '$completed / $total',
      style: theme.textTheme.labelMedium?.copyWith(color: labelColor),
    );
  }
}

class _TileControls extends StatelessWidget {
  const _TileControls({
    required this.completedCount,
    required this.isCompleted,
    required this.onIncrement,
    required this.onDecrement,
    required this.categoryTitle,
    required this.totalTarget,
  });

  final int completedCount;
  final bool isCompleted;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String categoryTitle;
  final int totalTarget;

  void _handleDecrement() {
    HapticFeedback.lightImpact();
    onDecrement();
  }

  void _handleIncrement() {
    if (isCompleted) return;
    final bool willComplete = completedCount + 1 >= totalTarget;
    if (willComplete) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    onIncrement();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Inset pill on top of the tile: the chip colour, so it stays a shade
    // apart from the card in both themes.
    final Color pill =
        theme.chipTheme.backgroundColor ?? theme.colorScheme.surface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (completedCount > 0) ...<Widget>[
          Semantics(
            label: context.l10n.homeRemoveServingSemantics(categoryTitle),
            button: true,
            child: GestureDetector(
              onTap: _handleDecrement,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 40,
                height: 44,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: pill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 16,
                      color: theme.textTheme.labelSmall?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
        ],
        Semantics(
          label: isCompleted
              ? context.l10n.homeCategoryCompletedSemantics(categoryTitle)
              : context.l10n.homeAddServingSemantics(
                  categoryTitle,
                  completedCount,
                  totalTarget,
                ),
          button: true,
          enabled: !isCompleted,
          child: GestureDetector(
            onTap: isCompleted ? null : _handleIncrement,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(child: AnimatedCheckButton(completed: isCompleted)),
            ),
          ),
        ),
      ],
    );
  }
}
