import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';

/// Pill-shaped chip for categories, filters and tabs.
///
/// Selected: the theme's primary fill. Unselected: the raised card surface.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    // Selected reads as the primary CTA (dark on light, lime on dark);
    // unselected is a raised card surface.
    final Color background = selected
        ? cs.primary
        : theme.cardTheme.color ?? cs.surface;
    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        onTap: onTap,
        pressedScale: 0.95,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              fontSize: 13,
              color: selected ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
