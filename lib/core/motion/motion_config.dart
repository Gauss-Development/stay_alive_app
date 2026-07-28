import 'package:flutter/widgets.dart';

/// Central accessibility switch for the motion system.
abstract final class MotionConfig {
  /// True when the platform asks to minimise motion.
  ///
  /// When reduced: entrance animations jump to their end state, decorative
  /// particles and bounces are disabled, and only simple opacity/progress
  /// changes remain.
  static bool reduceMotionOf(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }
}
