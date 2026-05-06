import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';

class GamificationProgressModel extends GamificationProgress {
  const GamificationProgressModel({
    required super.userId,
    required super.xp,
    required super.level,
    required super.currentLevelXp,
    required super.nextLevelXp,
    required super.currentStreak,
    required super.bestStreak,
    required super.completedDays,
    required super.badges,
    super.lastCompletedDate,
  });

  factory GamificationProgressModel.fromDocument(
    appwrite_models.Document document,
  ) {
    final Map<String, dynamic> data = document.data;
    final int xp = (data['xp'] as num?)?.toInt() ?? 0;
    final int level = (data['level'] as num?)?.toInt() ?? _levelFromXp(xp);
    return GamificationProgressModel(
      userId: data['user_id']?.toString() ?? document.$id,
      xp: xp,
      level: level,
      currentLevelXp: (level - 1) * 100,
      nextLevelXp: level * 100,
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      bestStreak: (data['best_streak'] as num?)?.toInt() ?? 0,
      completedDays: (data['completed_days'] as num?)?.toInt() ?? 0,
      lastCompletedDate: data['last_completed_date']?.toString(),
      badges: (data['badges'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic value) => value.toString())
          .toList(growable: false),
    );
  }

  factory GamificationProgressModel.fromDailyLogData({
    required String userId,
    required List<Map<String, dynamic>> logs,
  }) {
    final List<Map<String, dynamic>> sortedLogs = List<Map<String, dynamic>>.of(
      logs,
    )..sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            _dateKey(a).compareTo(_dateKey(b)),
      );

    int xp = 0;
    int completedDays = 0;
    int currentRun = 0;
    int bestStreak = 0;
    String? previousCompletedDate;
    String? lastCompletedDate;
    bool hasAnyProgress = false;
    bool hasPerfectDay = false;

    for (final Map<String, dynamic> log in sortedLogs) {
      final int totalCompleted = (log['total_completed'] as num?)?.toInt() ?? 0;
      final bool isFullyCompleted = log['is_fully_completed'] as bool? ?? false;
      final String logDate = _dateKey(log);
      if (totalCompleted > 0) {
        hasAnyProgress = true;
      }
      xp += totalCompleted * 5;
      if (!isFullyCompleted) {
        continue;
      }

      hasPerfectDay = true;
      completedDays += 1;
      xp += 25;
      if (previousCompletedDate == null ||
          _isNextDay(previousCompletedDate, logDate)) {
        currentRun += 1;
      } else {
        currentRun = 1;
      }
      if (currentRun > 1) {
        xp += 10;
      }
      if (currentRun > bestStreak) {
        bestStreak = currentRun;
      }
      previousCompletedDate = logDate;
      lastCompletedDate = logDate;
    }

    final int currentStreak = _isStreakCurrent(lastCompletedDate)
        ? currentRun
        : 0;
    final int level = _levelFromXp(xp);
    final List<String> badges = <String>[
      if (hasAnyProgress) 'first_log',
      if (hasPerfectDay) 'perfect_day',
      if (bestStreak >= 3 || currentStreak >= 3) 'three_day_streak',
      if (bestStreak >= 7 || currentStreak >= 7) 'seven_day_streak',
    ];

    return GamificationProgressModel(
      userId: userId,
      xp: xp,
      level: level,
      currentLevelXp: (level - 1) * 100,
      nextLevelXp: level * 100,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      completedDays: completedDays,
      lastCompletedDate: lastCompletedDate,
      badges: badges,
    );
  }

  Map<String, dynamic> toDocumentData({required String now}) {
    return <String, dynamic>{
      'user_id': userId,
      'xp': xp,
      'level': level,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'completed_days': completedDays,
      'last_completed_date': lastCompletedDate,
      'badges': badges,
      'updated_at': now,
    };
  }

  static int _levelFromXp(int xp) => (xp ~/ 100) + 1;

  static String _dateKey(Map<String, dynamic> data) {
    return data['log_date']?.toString() ?? '';
  }

  static bool _isNextDay(String previous, String current) {
    final DateTime? previousDate = DateTime.tryParse('${previous}T00:00:00Z');
    final DateTime? currentDate = DateTime.tryParse('${current}T00:00:00Z');
    if (previousDate == null || currentDate == null) {
      return false;
    }
    return currentDate.difference(previousDate).inDays == 1;
  }

  static bool _isStreakCurrent(String? lastCompletedDate) {
    if (lastCompletedDate == null) {
      return false;
    }
    final DateTime? parsed = DateTime.tryParse('${lastCompletedDate}T00:00:00Z');
    if (parsed == null) {
      return false;
    }
    final DateTime today = DateTime.now().toUtc();
    final DateTime todayDate = DateTime.utc(today.year, today.month, today.day);
    final int daysSince = todayDate.difference(parsed).inDays;
    return daysSince == 0 || daysSince == 1;
  }
}
