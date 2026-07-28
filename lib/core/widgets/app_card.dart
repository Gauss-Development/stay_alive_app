import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';

/// Universal soft card: white (or dark) rounded container with a light shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.color = AppColors.white,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
