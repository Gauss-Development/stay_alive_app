import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

class CategoryProgressTile extends StatelessWidget {
  const CategoryProgressTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  final DailyLogItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = item.isCompleted;

    final ColorScheme colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isCompleted
                ? colors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            _CategoryIcon(
              iconKey: item.category.iconKey,
              isCompleted: isCompleted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? colors.onSurface
                          : colors.onSurface.withValues(alpha: 0.8),
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
            const SizedBox(width: 8),
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
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconKey, required this.isCompleted});

  final String iconKey;
  final bool isCompleted;

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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.primary.withValues(alpha: 0.1)
            : colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _icons[iconKey.toLowerCase()] ??
            Icons.check_circle_outline_rounded,
        color: isCompleted
            ? colors.primary
            : colors.onSurface.withValues(alpha: 0.35),
        size: 20,
      ),
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (total <= 1) {
      return Text(
        isCompleted ? 'Done' : 'Tap to complete',
        style: TextStyle(
          fontSize: 12,
          color: isCompleted
              ? colors.primary
              : colors.onSurface.withValues(alpha: 0.35),
        ),
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
                    ? colors.primary
                    : colors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }),
      );
    }

    return Text(
      '$completed / $total',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isCompleted
            ? colors.primary
            : colors.onSurface.withValues(alpha: 0.35),
      ),
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (completedCount > 0) ...<Widget>[
          Semantics(
            label: 'Decrease $categoryTitle',
            button: true,
            child: GestureDetector(
              onTap: _handleDecrement,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 15,
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Semantics(
          label: isCompleted
              ? '$categoryTitle completed'
              : 'Add $categoryTitle serving ($completedCount of $totalTarget)',
          button: true,
          enabled: !isCompleted,
          child: GestureDetector(
            onTap: isCompleted ? null : _handleIncrement,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : Icons.add,
                    size: 18,
                    color: isCompleted ? colors.onPrimary : colors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
