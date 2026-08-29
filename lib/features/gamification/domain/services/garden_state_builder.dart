import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

/// Builds a [GardenState] from the authoritative profile + recent logs.
class GardenStateBuilder {
  const GardenStateBuilder();

  GardenState build({
    required UserGameProfile profile,
    required List<DailyLog> recentLogs,
    DailyLog? todayLog,
    DateTime? referenceDate,
  }) {
    // `now` keeps the time of day (mood needs the hour); `reference` is the
    // date-only key used by streak/health lookups.
    final DateTime now = referenceDate ?? DateTime.now();
    final DateTime reference = _dateOnly(now);
    final bool wilting = _isWilting(profile, reference);
    final double todayGrowth = _todayGrowth(todayLog);
    return GardenState(
      stage: GardenState.stageForLevel(profile.currentLevel),
      mood: _moodFor(
        hour: now.hour,
        wilting: wilting,
        todayGrowth: todayGrowth,
      ),
      health: _healthFromLogs(recentLogs, reference),
      wilting: wilting,
      todayGrowth: todayGrowth,
      levelTitle: profile.currentLevel.title,
      level: profile.currentLevel.level,
    );
  }

  /// Mood is a pure projection of clock + progress. It lives here rather than
  /// in the widget so that a rebuild for an unrelated reason can never flip
  /// the sprout's face mid-frame.
  SproutMood _moodFor({
    required int hour,
    required bool wilting,
    required double todayGrowth,
  }) {
    if (hour >= 22 || hour < 6) {
      return SproutMood.sleeping;
    }
    if (todayGrowth >= 1.0) {
      return SproutMood.celebrating;
    }
    if (wilting || todayGrowth == 0) {
      return SproutMood.waiting;
    }
    return SproutMood.happy;
  }

  double _todayGrowth(DailyLog? todayLog) {
    if (todayLog == null || todayLog.totalTarget <= 0) {
      return 0;
    }
    return (todayLog.totalCompleted / todayLog.totalTarget).clamp(0.0, 1.0);
  }

  double _healthFromLogs(List<DailyLog> logs, DateTime reference) {
    if (logs.isEmpty) {
      return 0.35;
    }

    int activeDays = 0;
    for (int i = 0; i < 7; i++) {
      final DateTime day = reference.subtract(Duration(days: i));
      final DailyLog? log = _logForDate(logs, _dateKey(day));
      if (log != null && log.totalCompleted > 0) {
        activeDays += 1;
      }
    }
    return (0.25 + (activeDays / 7) * 0.75).clamp(0.2, 1.0);
  }

  bool _isWilting(UserGameProfile profile, DateTime reference) {
    if (profile.currentStreak <= 0 && profile.activityStreak <= 0) {
      return profile.totalXp > 0;
    }

    final String yesterday =
        _dateKey(reference.subtract(const Duration(days: 1)));
    final bool yesterdayPerfect = profile.completedDates.contains(yesterday);
    final bool freezeUsed =
        profile.streakFreezeUsedDates.contains(yesterday);
    if (yesterdayPerfect || freezeUsed) {
      return false;
    }

    final String today = _dateKey(reference);
    final bool todayPerfect = profile.completedDates.contains(today);
    return !todayPerfect && profile.activityStreak > 0;
  }

  DailyLog? _logForDate(List<DailyLog> logs, String dateKey) {
    for (final DailyLog log in logs) {
      if (log.dateKey == dateKey) {
        return log;
      }
    }
    return null;
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
