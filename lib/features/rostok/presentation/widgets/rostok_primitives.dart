import 'package:flutter/material.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';

/// Full-bleed Росток screen: solid background + SafeArea. The mockup phone
/// frame and fake `9:41` status bar are intentionally dropped for on-device use.
class RostokScaffold extends StatelessWidget {
  const RostokScaffold({
    required this.child,
    this.background = RostokColors.surface,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 0),
    super.key,
  });

  final Widget child;
  final Color background;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Selectable pill used for the home category filter row.
class RostokPill extends StatelessWidget {
  const RostokPill({
    required this.label,
    this.active = false,
    this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: active ? RostokColors.ink : RostokColors.chipBg,
          borderRadius: RostokDimens.pill,
        ),
        child: Text(
          label,
          style: RostokText.body(
            size: 14,
            weight: FontWeight.w600,
            color: active ? Colors.white : RostokColors.chipText,
          ),
        ),
      ),
    );
  }
}

/// Dot + label tag, e.g. "Уровень 4 · Побег" or "ЧЕЛЛЕНДЖ НЕДЕЛИ".
class RostokAccentTag extends StatelessWidget {
  const RostokAccentTag({
    required this.label,
    this.accent = RostokColors.accent,
    this.onDark = false,
    this.uppercase = false,
    super.key,
  });

  final String label;
  final Color accent;
  final bool onDark;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: onDark ? RostokColors.darkChip : RostokColors.chipBg,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              style: RostokText.body(
                size: 12,
                weight: FontWeight.w700,
                color: onDark ? accent : RostokColors.chipText,
                letterSpacing: uppercase ? 0.5 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular icon button used for back / settings actions.
class RostokCircleButton extends StatelessWidget {
  const RostokCircleButton({
    required this.icon,
    this.onTap,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RostokColors.card,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 20, color: RostokColors.inkText),
        ),
      ),
    );
  }
}

/// Back button + centered title + optional trailing action (44px slot).
class RostokHeader extends StatelessWidget {
  const RostokHeader({
    required this.title,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        RostokCircleButton(icon: Icons.chevron_left, onTap: onBack),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: RostokText.display(size: 19, weight: FontWeight.w600),
          ),
        ),
        SizedBox(width: 44, height: 44, child: trailing),
      ],
    );
  }
}

/// Rounded linear progress bar with an animated fill.
class RostokProgressBar extends StatelessWidget {
  const RostokProgressBar({
    required this.fraction,
    this.height = 12,
    this.background = RostokColors.chipBg,
    this.fill = RostokColors.accent,
    this.gradient,
    super.key,
  });

  final double fraction;
  final double height;
  final Color background;
  final Color fill;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: background,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: fraction.clamp(0, 1)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? _) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: gradient == null ? fill : null,
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The Росток leaf mascot: a rounded, tilted green blob.
class RostokMascot extends StatelessWidget {
  const RostokMascot({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.26, // ~ -15deg
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: RostokColors.mascot,
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
