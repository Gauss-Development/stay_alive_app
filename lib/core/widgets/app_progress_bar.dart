import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/app_durations.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';

/// Pill-shaped animated progress bar.
///
/// The fill animates from the previous value to the new one with the
/// standard motion tokens; under reduced motion it updates instantly.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    this.backgroundColor = AppColors.border,
    this.valueColor = AppColors.lime,
    this.height = 8,
    super.key,
  });

  /// 0.0–1.0.
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionConfig.reduceMotionOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.clamp(0, 1)),
          duration: reduceMotion ? Duration.zero : AppDurations.slow,
          curve: AppCurves.standard,
          builder: (BuildContext context, double animatedValue, Widget? _) {
            return DecoratedBox(
              decoration: BoxDecoration(color: backgroundColor),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animatedValue,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: valueColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
