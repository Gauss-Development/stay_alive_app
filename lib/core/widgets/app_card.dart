import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';

/// Universal soft card: rounded container with a light shadow.
///
/// [color] defaults to the theme's card colour rather than a fixed white, so
/// the card follows the light/dark switch. Callers that pass an explicit
/// colour (the dark hero cards) keep it in both themes.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
    );
  }
}
