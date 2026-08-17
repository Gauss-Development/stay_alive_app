import 'package:flutter/widgets.dart';
import 'package:stay_alive/core/motion/motion_config.dart';

/// Shared one-shot entrance scaffold for the animation widgets.
///
/// Builds a controller spanning `delay + duration`, exposes [intervalStart] (the
/// fraction of the timeline taken by the delay, so the delay is modeled as a
/// leading gap inside a single [Interval]), plays once on the first
/// [didChangeDependencies], and honors reduced motion by jumping to the end
/// state. Widgets whose painter draws nothing at `t == 1` (e.g. a burst) stay
/// invisible under reduced motion, which is the intended behavior.
mixin EntranceAnimation<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController entranceController;

  /// Start of the animation's [Interval] — the delay as a fraction of the total.
  late final double intervalStart;

  bool _started = false;

  Duration get entranceDelay;
  Duration get entranceDuration;

  /// Call from [initState] before building animations off [entranceController].
  void initEntrance() {
    final int total =
        entranceDelay.inMilliseconds + entranceDuration.inMilliseconds;
    entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    intervalStart = total == 0 ? 0 : entranceDelay.inMilliseconds / total;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MotionConfig.reduceMotionOf(context)) {
      entranceController.value = 1;
    } else {
      entranceController.forward();
    }
  }

  @override
  void dispose() {
    entranceController.dispose();
    super.dispose();
  }
}
