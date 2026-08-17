import 'package:flutter/animation.dart';

/// Motion tokens: canonical easing curves.
abstract final class AppCurves {
  /// Default for almost everything.
  static const Curve standard = Curves.easeOutCubic;

  /// Card / badge / sprout entrances with a soft overshoot.
  static const Curve emphasized = Curves.easeOutBack;

  /// Screen switches and smooth state changes.
  static const Curve soft = Curves.easeInOutCubic;

  /// Points, level up, reward only.
  static const Curve bounce = Curves.elasticOut;
}
