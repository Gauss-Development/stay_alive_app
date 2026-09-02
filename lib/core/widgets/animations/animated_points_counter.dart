import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';

/// Points counter that rolls smoothly between values.
///
/// On increase it also plays a short scale pop and (unless reduced motion)
/// floats a `+N` label upwards next to the number.
class AnimatedPointsCounter extends StatefulWidget {
  const AnimatedPointsCounter({
    required this.value,
    this.style,
    this.suffix = '',
    this.showFloatingDelta = true,
    this.deltaColor = AppColors.lime,
    super.key,
  });

  final int value;
  final TextStyle? style;

  /// Appended after the number, e.g. ' pts'. Callers pass a localized value.
  final String suffix;

  /// Show the floating `+N` label on increases.
  final bool showFloatingDelta;
  final Color deltaColor;

  @override
  State<AnimatedPointsCounter> createState() => _AnimatedPointsCounterState();
}

class _AnimatedPointsCounterState extends State<AnimatedPointsCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _effects;
  late final Animation<double> _pop;

  int _delta = 0;

  @override
  void initState() {
    super.initState();
    _effects = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _pop = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 16,
      ),
      TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 70),
    ]).animate(_effects);
  }

  @override
  void didUpdateWidget(AnimatedPointsCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value > oldWidget.value &&
        !MotionConfig.reduceMotionOf(context)) {
      _delta = widget.value - oldWidget.value;
      _effects.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _effects.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionConfig.reduceMotionOf(context);
    final TextStyle style = widget.style ?? AppTextStyles.points;

    final Widget number = TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: widget.value.toDouble(),
        end: widget.value.toDouble(),
      ),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 650),
      curve: AppCurves.standard,
      builder: (BuildContext context, double animated, Widget? _) {
        return Text('${animated.round()}${widget.suffix}', style: style);
      },
    );

    if (reduceMotion || !widget.showFloatingDelta) {
      return number;
    }

    return AnimatedBuilder(
      animation: _effects,
      builder: (BuildContext context, Widget? child) {
        final double t = _effects.value;
        final bool showDelta = _delta > 0 && t > 0 && t < 1;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Transform.scale(scale: _pop.value, child: child),
            if (showDelta)
              Positioned(
                top: -8 - 24 * Curves.easeOutCubic.transform(t),
                right: -4,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (1 - const Interval(0.45, 1).transform(t)).clamp(
                      0,
                      1,
                    ),
                    child: Text(
                      '+$_delta',
                      style: context.text.labelLarge?.copyWith(
                        color: widget.deltaColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: number,
    );
  }
}
