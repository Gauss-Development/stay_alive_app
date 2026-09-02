import 'package:flutter/material.dart';

/// Circular soft icon button — back arrows, settings, profile shortcuts.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    this.onTap,
    this.size = 44,
    this.background,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  /// Defaults to the theme's card surface.
  final Color? background;

  /// Defaults to the theme's primary ink.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: background ?? theme.cardTheme.color ?? theme.colorScheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.45,
            color: iconColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
