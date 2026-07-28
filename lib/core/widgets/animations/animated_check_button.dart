import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Circular add/check button for logging a serving.
///
/// * idle — white circle with a plus;
/// * completed — dark circle, the check pops in with a bounce and a single
///   lime pulse ring expands outward.
///
/// Purely visual: tap handling stays with the parent so existing gesture /
/// semantics logic keeps working.
class AnimatedCheckButton extends StatefulWidget {
  const AnimatedCheckButton({
    required this.completed,
    this.size = 42,
    super.key,
  });

  final bool completed;
  final double size;

  @override
  State<AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      // No entrance animation for items that are already completed.
      value: widget.completed ? 1 : 0,
    );
    _checkScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: AppCurves.bounce),
    );
    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 1, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed == oldWidget.completed) {
      return;
    }
    if (!widget.completed) {
      _controller.value = 0;
      return;
    }
    if (MotionConfig.reduceMotionOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool completed = widget.completed;
    final double size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          // One-shot lime pulse ring on completion.
          if (completed)
            AnimatedBuilder(
              animation: _pulse,
              builder: (BuildContext context, Widget? _) {
                final double t = _pulse.value;
                if (t <= 0 || t >= 1) {
                  return const SizedBox.shrink();
                }
                return Opacity(
                  opacity: (1 - t).clamp(0, 1),
                  child: Transform.scale(
                    scale: 1 + t * 0.55,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lime, width: 2),
                      ),
                    ),
                  ),
                );
              },
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: AppCurves.standard,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: completed ? AppColors.dark : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed ? AppColors.dark : AppColors.border,
                width: 2,
              ),
            ),
            child: completed
                ? ScaleTransition(
                    scale: _checkScale,
                    child: Icon(
                      Icons.check_rounded,
                      size: size * 0.48,
                      color: AppColors.lime,
                    ),
                  )
                : Icon(
                    Icons.add_rounded,
                    size: size * 0.48,
                    color: AppColors.textMuted,
                  ),
          ),
        ],
      ),
    );
  }
}
