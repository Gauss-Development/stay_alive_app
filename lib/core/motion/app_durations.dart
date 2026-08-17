/// Motion tokens: canonical animation durations.
///
/// Every animation in the app must use one of these values so the whole
/// product moves at the same rhythm.
abstract final class AppDurations {
  /// Micro-interactions: press feedback, chip selection.
  static const Duration fast = Duration(milliseconds: 160);

  /// Standard entrances and state changes.
  static const Duration medium = Duration(milliseconds: 280);

  /// Larger entrances, progress fills, counters.
  static const Duration slow = Duration(milliseconds: 450);

  /// Reward moments: points bounce, burst.
  static const Duration reward = Duration(milliseconds: 800);

  /// Full celebration sequences (level up).
  static const Duration celebration = Duration(milliseconds: 1200);

  /// Delay step between items of a staggered list.
  static const Duration staggerStep = Duration(milliseconds: 55);
}
