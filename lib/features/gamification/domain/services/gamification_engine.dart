import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class GamificationEngine {
  const GamificationEngine();

  static const int xpPerServing = 5;
  static const int xpCategoryCompleted = 15;
  static const int xpPerfectDay = 50;
  static const int xpStreakDay = 15;
  static const int xpFirstLogOfDay = 10;
  static const int xpEarlyBirdDay = 5;

  static const Map<BadgeId, int> badgeXpBonuses = <BadgeId, int>{
    BadgeId.firstStep: 25,
    BadgeId.perfectDay: 50,
    BadgeId.weekStreak: 100,
    BadgeId.ironWill: 300,
    BadgeId.earlyBird: 75,
    BadgeId.centurion: 500,
  };

  UserGameProfile reconcile({
    required String userId,
    required List<DailyLog> logs,
    DateTime? referenceDate,
  }) {
    final DateTime reference = _dateOnly(referenceDate ?? DateTime.now());
    final List<DailyLog> sortedLogs = List<DailyLog>.of(logs)
      ..sort(
        (DailyLog a, DailyLog b) => a.dateKey.compareTo(b.dateKey),
      );

    int xp = 0;
    int perfectRun = 0;
    String? previousPerfectDate;
    final List<String> completedDates = <String>[];
    final Set<String> earlyLogDates = <String>{};
    final Set<String> completedCategoryIds = <String>{};
    final Map<BadgeId, DateTime> earnedBadges = <BadgeId, DateTime>{};

    for (final DailyLog log in sortedLogs) {
      final bool hadActivity = log.totalCompleted > 0;
      if (!hadActivity) {
        continue;
      }

      if (log.items.any((DailyLogItem item) => item.isCompleted)) {
        for (final DailyLogItem item in log.items) {
          if (item.isCompleted) {
            completedCategoryIds.add(item.categoryId);
          }
        }
        _awardBadge(
          earnedBadges,
          BadgeId.firstStep,
          _dateAtMidnight(log.logDate),
        );
      }

      xp += xpFirstLogOfDay;

      for (final DailyLogItem item in log.items) {
        final int cappedCount = item.completedCount > item.targetCount
            ? item.targetCount
            : item.completedCount;
        xp += cappedCount * xpPerServing;
        if (item.isCompleted) {
          xp += xpCategoryCompleted;
        }
      }

      if (_isEarlyBirdDay(log)) {
        earlyLogDates.add(log.dateKey);
        xp += xpEarlyBirdDay;
        if (earlyLogDates.length >= 5) {
          _awardBadge(
            earnedBadges,
            BadgeId.earlyBird,
            _dateAtMidnight(log.logDate),
          );
        }
      }

      if (!log.isFullyCompleted) {
        continue;
      }

      completedDates.add(log.dateKey);
      xp += xpPerfectDay;
      _awardBadge(
        earnedBadges,
        BadgeId.perfectDay,
        _dateAtMidnight(log.logDate),
      );

      if (previousPerfectDate == null ||
          _isNextDay(previousPerfectDate, log.dateKey)) {
        perfectRun += 1;
      } else {
        perfectRun = 1;
      }

      if (perfectRun >= 2) {
        xp += xpStreakDay;
      }

      if (perfectRun >= 7) {
        _awardBadge(
          earnedBadges,
          BadgeId.weekStreak,
          _dateAtMidnight(log.logDate),
        );
      }
      if (perfectRun >= 30) {
        _awardBadge(
          earnedBadges,
          BadgeId.ironWill,
          _dateAtMidnight(log.logDate),
        );
      }
      if (completedDates.length >= 100) {
        _awardBadge(
          earnedBadges,
          BadgeId.centurion,
          _dateAtMidnight(log.logDate),
        );
      }

      previousPerfectDate = log.dateKey;
    }

    for (final MapEntry<BadgeId, int> entry in badgeXpBonuses.entries) {
      if (earnedBadges.containsKey(entry.key)) {
        xp += entry.value;
      }
    }

    final int longestPerfectStreak = _longestConsecutiveStreak(completedDates);
    final int perfectStreak = _currentConsecutiveStreak(
      dates: completedDates,
      reference: reference,
    );
    final int activityStreak = _calculateActivityStreak(
      sortedLogs: sortedLogs,
      reference: reference,
    );

    final GameLevel currentLevel = GameLevelTable.forXp(xp);
    final List<EarnedBadge> badges = earnedBadges.entries
        .map(
          (MapEntry<BadgeId, DateTime> entry) => EarnedBadge(
            id: entry.key,
            earnedAt: entry.value,
          ),
        )
        .toList(growable: false)
      ..sort(
        (EarnedBadge a, EarnedBadge b) =>
            a.earnedAt.compareTo(b.earnedAt),
      );

    return UserGameProfile(
      userId: userId,
      totalXp: xp,
      currentLevel: currentLevel,
      currentStreak: perfectStreak,
      longestStreak: longestPerfectStreak,
      activityStreak: activityStreak,
      completedDates: completedDates,
      earlyLogDates: earlyLogDates.toList(growable: false)..sort(),
      earnedBadges: badges,
      totalCategoriesCompleted: completedCategoryIds.length,
    );
  }

  List<GamificationEffectCandidate> diffProfiles(
    UserGameProfile? previous,
    UserGameProfile next,
  ) {
    if (previous == null) {
      return const <GamificationEffectCandidate>[];
    }

    final List<GamificationEffectCandidate> effects =
        <GamificationEffectCandidate>[];

    if (next.currentLevel.level > previous.currentLevel.level) {
      effects.add(GamificationEffectCandidate.levelUp(next.currentLevel));
    }

    final Set<BadgeId> previousBadges = previous.earnedBadges
        .map((EarnedBadge badge) => badge.id)
        .toSet();
    for (final EarnedBadge badge in next.earnedBadges) {
      if (!previousBadges.contains(badge.id)) {
        effects.add(GamificationEffectCandidate.badgeUnlocked(badge));
      }
    }

    return effects;
  }

  int _longestConsecutiveStreak(List<String> dates) {
    if (dates.isEmpty) {
      return 0;
    }

    int longest = 1;
    int current = 1;
    for (int index = 1; index < dates.length; index += 1) {
      if (_isNextDay(dates[index - 1], dates[index])) {
        current += 1;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 1;
      }
    }
    return longest;
  }

  int _currentConsecutiveStreak({
    required List<String> dates,
    required DateTime reference,
  }) {
    if (dates.isEmpty || !_isStreakCurrent(dates.last, reference)) {
      return 0;
    }

    int streak = 1;
    for (int index = dates.length - 2; index >= 0; index -= 1) {
      if (_isNextDay(dates[index], dates[index + 1])) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateActivityStreak({
    required List<DailyLog> sortedLogs,
    required DateTime reference,
  }) {
    final List<String> activeDates = sortedLogs
        .where((DailyLog log) => log.totalCompleted > 0)
        .map((DailyLog log) => log.dateKey)
        .toList(growable: false);
    if (activeDates.isEmpty) {
      return 0;
    }

    final String lastActiveDate = activeDates.last;
    if (!_isStreakCurrent(lastActiveDate, reference)) {
      return 0;
    }

    int streak = 1;
    for (int index = activeDates.length - 2; index >= 0; index -= 1) {
      if (_isNextDay(activeDates[index], activeDates[index + 1])) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  bool _isEarlyBirdDay(DailyLog log) {
    for (final DailyLogItem item in log.items) {
      if (item.completedCount <= 0) {
        continue;
      }
      final DateTime local = item.updatedAt.toLocal();
      if (local.hour < 9) {
        return true;
      }
    }
    return false;
  }

  void _awardBadge(
    Map<BadgeId, DateTime> earnedBadges,
    BadgeId badgeId,
    DateTime earnedAt,
  ) {
    earnedBadges.putIfAbsent(badgeId, () => earnedAt);
  }

  bool _isStreakCurrent(String? lastDate, DateTime reference) {
    if (lastDate == null) {
      return false;
    }
    final DateTime? parsed = DateTime.tryParse('${lastDate}T00:00:00');
    if (parsed == null) {
      return false;
    }
    final int daysSince = _dateOnly(reference).difference(_dateOnly(parsed)).inDays;
    return daysSince == 0 || daysSince == 1;
  }

  bool _isNextDay(String previous, String current) {
    final DateTime? previousDate = DateTime.tryParse('${previous}T00:00:00');
    final DateTime? currentDate = DateTime.tryParse('${current}T00:00:00');
    if (previousDate == null || currentDate == null) {
      return false;
    }
    return _dateOnly(currentDate).difference(_dateOnly(previousDate)).inDays == 1;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _dateAtMidnight(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

sealed class GamificationEffectCandidate {
  const GamificationEffectCandidate();

  const factory GamificationEffectCandidate.levelUp(GameLevel level) =
      LevelUpEffectCandidate;

  const factory GamificationEffectCandidate.badgeUnlocked(EarnedBadge badge) =
      BadgeUnlockedEffectCandidate;
}

class LevelUpEffectCandidate extends GamificationEffectCandidate {
  const LevelUpEffectCandidate(this.level);

  final GameLevel level;
}

class BadgeUnlockedEffectCandidate extends GamificationEffectCandidate {
  const BadgeUnlockedEffectCandidate(this.badge);

  final EarnedBadge badge;
}
