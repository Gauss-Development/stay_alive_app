import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// The «росток» mascot — a soft green leaf drawn from rounded shapes.
class SproutIcon extends StatelessWidget {
  const SproutIcon({this.size = 40, this.color = AppColors.green, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.26,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size / 2),
            topRight: Radius.circular(size / 2),
            bottomRight: Radius.circular(size / 2),
            bottomLeft: Radius.circular(size * 0.2),
          ),
        ),
      ),
    );
  }
}

/// Sprout inside a glowing circle — hero of auth / reward screens.
class SproutEmblem extends StatelessWidget {
  const SproutEmblem({
    this.size = 120,
    this.glowColor = AppColors.lime,
    super.key,
  });

  final double size;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            glowColor.withValues(alpha: 0.35),
            glowColor.withValues(alpha: 0),
          ],
          stops: const <double>[0.1, 1],
        ),
      ),
      child: Container(
        width: size * 0.68,
        height: size * 0.68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SproutIcon(size: size * 0.32),
      ),
    );
  }
}
