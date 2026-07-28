import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Circular soft icon button — back arrows, settings, profile shortcuts.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    this.onTap,
    this.size = 44,
    this.background = AppColors.white,
    this.iconColor = AppColors.textPrimary,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.45, color: iconColor),
        ),
      ),
    );
  }
}
