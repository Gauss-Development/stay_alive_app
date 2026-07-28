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
  static const double premiumXpMultiplier = 1.25;
  static const int premiumStreakFreezeAllowance = 2;

  static const Map<BadgeId, int> badgeXpBonuses = <BadgeId, int>{
    BadgeId.firstStep: 25,
    BadgeId.perfectDay: 50,
    BadgeId.weekStreak: 100,
    BadgeId.ironWill: 300,
    BadgeId.earlyBird: 75,
    BadgeId.centurion: 500,
    BadgeId.winterWellness: 120,
    BadgeId.secretKeeper: 200,
    BadgeId.patron: 150,
  };

  UserGameProfile reconcile({
    required String userId,
    required List<DailyLog> logs,
    DateTime? referenceDate,
    bool isPremium = false,
    int streakFreezesRemaining = 0,
    List<String> streakFreezeUsedDates = const <String>[],
  }) {
    final DateTime reference = _dateOnly(referenceDate ?? DateTime.now());
    final List<DailyLog> sortedLogs = List<DailyLog>.of(logs)
      ..sort((DailyLog a, DailyLog b) => a.dateKey.compareTo(b.dateKey));

    int xp = 0;
    int perfectRun = 0;
    String? previousPerfectDate;
    final List<String> completedDates = <String>[];
    final Set<String> earlyLogDates = <String>{};
    final Set<String> completedCategoryIds = <String>{};
    final Map<BadgeId, DateTime> earnedBadges = <BadgeId, DateTime>{};
    int winterPerfectDays = 0;

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
        _awardBadgeIfAvailable(
          earnedBadges,
          BadgeId.firstStep,
          _dateAtMidnight(log.logDate),
          reference,
          isPremium: isPremium,
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
          _awardBadgeIfAvailable(
            earnedBadges,
            BadgeId.earlyBird,
            _dateAtMidnight(log.logDate),
            reference,
            isPremium: isPremium,
          );
        }
      }

      if (!log.isFullyCompleted) {
        continue;
      }

      completedDates.add(log.dateKey);
      xp += xpPerfectDay;
      _awardBadgeIfAvailable(
        earnedBadges,
        BadgeId.perfectDay,
        _dateAtMidnight(log.logDate),
        reference,
        isPremium: isPremium,
      );

      if (_isWinterMonth(log.logDate.month)) {
        winterPerfectDays += 1;
        if (winterPerfectDays >= 5) {
          _awardBadgeIfAvailable(
            earnedBadges,
            BadgeId.winterWellness,
            _dateAtMidnight(log.logDate),
            reference,
            isPremium: isPremium,
          );
        }
      }

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
        _awardBadgeIfAvailable(
          earnedBadges,
          BadgeId.weekStreak,
          _dateAtMidnight(log.logDate),
          reference,
          isPremium: isPremium,
        );
      }
      if (perfectRun >= 14) {
        _awardBadgeIfAvailable(
          earnedBadges,
          BadgeId.secretKeeper,
          _dateAtMidnight(log.logDate),
          reference,
          isPremium: isPremium,
        );
      }
      if (perfectRun >= 30) {
        _awardBadgeIfAvailable(
          earnedBadges,
          BadgeId.ironWill,
          _dateAtMidnight(log.logDate),
          reference,
          isPremium: isPremium,
        );
      }
      if (completedDates.length >= 100) {
        _awardBadgeIfAvailable(
          earnedBadges,
          BadgeId.centurion,
          _dateAtMidnight(log.logDate),
          reference,
          isPremium: isPremium,
        );
      }

      previousPerfectDate = log.dateKey;
    }

    if (isPremium) {
      _awardBadgeIfAvailable(
        earnedBadges,
        BadgeId.patron,
        reference,
        reference,
        isPremium: true,
      );
    }

    for (final MapEntry<BadgeId, int> entry in badgeXpBonuses.entries) {
      if (earnedBadges.containsKey(entry.key)) {
        xp += entry.value;
      }
    }

    if (isPremium) {
      xp = (xp * premiumXpMultiplier).round();
    }

    final List<String> freezeUsedDates = List<String>.of(streakFreezeUsedDates);
    int freezesRemaining = isPremium
        ? _premiumFreezeAllowance(streakFreezesRemaining)
        : streakFreezesRemaining;

    final _StreakFreezeResult freezeResult = _applyAutoStreakFreeze(
      completedDates: completedDates,
      reference: reference,
      freezesRemaining: freezesRemaining,
      freezeUsedDates: freezeUsedDates,
    );
    freezesRemaining = freezeResult.freezesRemaining;
    final List<String> effectiveCompletedDates = freezeResult.completedDates;

    final int longestPerfectStreak = _longestConsecutiveStreak(
      effectiveCompletedDates,
      freezeUsedDates,
    );
    final int perfectStreak = _currentConsecutiveStreak(
      dates: effectiveCompletedDates,
      reference: reference,
      freezeUsedDates: freezeUsedDates,
    );
    final int activityStreak = _calculateActivityStreak(
      sortedLogs: sortedLogs,
      reference: reference,
    );

    final GameLevel currentLevel = GameLevelTable.forXp(xp);
    final List<EarnedBadge> badges =
        earnedBadges.entries
            .map(
              (MapEntry<BadgeId, DateTime> entry) =>
                  EarnedBadge(id: entry.key, earnedAt: entry.value),
            )
            .toList(growable: false)
          ..sort(
            (EarnedBadge a, EarnedBadge b) => a.earnedAt.compareTo(b.earnedAt),
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
      streakFreezesRemaining: freezesRemaining,
      streakFreezeUsedDates: freezeUsedDates,
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

  int _premiumFreezeAllowance(int currentRemaining) {
    if (currentRemaining >= premiumStreakFreezeAllowance) {
      return currentRemaining;
    }
    return premiumStreakFreezeAllowance;
  }

  _StreakFreezeResult _applyAutoStreakFreeze({
    required List<String> completedDates,
    required DateTime reference,
    required int freezesRemaining,
    required List<String> freezeUsedDates,
  }) {
    if (completedDates.isEmpty || freezesRemaining <= 0) {
      return _StreakFreezeResult(
        completedDates: completedDates,
        freezesRemaining: freezesRemaining,
      );
    }

    final String lastPerfectDate = completedDates.last;
    if (_isStreakCurrent(lastPerfectDate, reference)) {
      return _StreakFreezeResult(
        completedDates: completedDates,
        freezesRemaining: freezesRemaining,
      );
    }

    final DateTime? lastPerfect = DateTime.tryParse(
      '${lastPerfectDate}T00:00:00',
    );
    if (lastPerfect == null) {
      return _StreakFreezeResult(
        completedDates: completedDates,
        freezesRemaining: freezesRemaining,
      );
    }

    final int daysSince = _dateOnly(
      reference,
    ).difference(_dateOnly(lastPerfect)).inDays;
    if (daysSince != 2) {
      return _StreakFreezeResult(
        completedDates: completedDates,
        freezesRemaining: freezesRemaining,
      );
    }

    final String missedDate = _dateKey(
      _dateOnly(reference).subtract(const Duration(days: 1)),
    );
    if (freezeUsedDates.contains(missedDate)) {
      return _StreakFreezeResult(
        completedDates: completedDates,
        freezesRemaining: freezesRemaining,
      );
    }

    final List<String> bridgedDates = List<String>.of(completedDates)
      ..add(missedDate)
      ..sort();
    freezeUsedDates.add(missedDate);

    return _StreakFreezeResult(
      completedDates: bridgedDates,
      freezesRemaining: freezesRemaining - 1,
    );
  }

  int _longestConsecutiveStreak(
    List<String> dates,
    List<String> freezeUsedDates,
  ) {
    if (dates.isEmpty) {
      return 0;
    }

    int longest = 1;
    int current = 1;
    for (int index = 1; index < dates.length; index += 1) {
      if (_isConnectedDay(dates[index - 1], dates[index], freezeUsedDates)) {
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
    required List<String> freezeUsedDates,
  }) {
    if (dates.isEmpty || !_isStreakCurrent(dates.last, reference)) {
      return 0;
    }

    int streak = 1;
    for (int index = dates.length - 2; index >= 0; index -= 1) {
      if (_isConnectedDay(dates[index], dates[index + 1], freezeUsedDates)) {
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

  bool _isConnectedDay(
    String previous,
    String current,
    List<String> freezeUsedDates,
  ) {
    if (_isNextDay(previous, current)) {
      return true;
    }

    final DateTime? previousDate = DateTime.tryParse('${previous}T00:00:00');
    final DateTime? currentDate = DateTime.tryParse('${current}T00:00:00');
    if (previousDate == null || currentDate == null) {
      return false;
    }

    final int gap = _dateOnly(
      currentDate,
    ).difference(_dateOnly(previousDate)).inDays;
    if (gap != 2) {
      return false;
    }

    final String bridgeDate = _dateKey(
      _dateOnly(previousDate).add(const Duration(days: 1)),
    );
    return freezeUsedDates.contains(bridgeDate);
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

  void _awardBadgeIfAvailable(
    Map<BadgeId, DateTime> earnedBadges,
    BadgeId badgeId,
    DateTime earnedAt,
    DateTime reference, {
    required bool isPremium,
  }) {
    final BadgeDefinition definition = BadgeDefinition.all[badgeId]!;
    if (definition.requiresPremium && !isPremium) {
      return;
    }
    if (!definition.isAvailableOn(reference)) {
      return;
    }
    earnedBadges.putIfAbsent(badgeId, () => earnedAt);
  }

  bool _isWinterMonth(int month) {
    return month == 12 || month == 1 || month == 2;
  }

  bool _isStreakCurrent(String? lastDate, DateTime reference) {
    if (lastDate == null) {
      return false;
    }
    final DateTime? parsed = DateTime.tryParse('${lastDate}T00:00:00');
    if (parsed == null) {
      return false;
    }
    final int daysSince = _dateOnly(
      reference,
    ).difference(_dateOnly(parsed)).inDays;
    return daysSince == 0 || daysSince == 1;
  }

  bool _isNextDay(String previous, String current) {
    final DateTime? previousDate = DateTime.tryParse('${previous}T00:00:00');
    final DateTime? currentDate = DateTime.tryParse('${current}T00:00:00');
    if (previousDate == null || currentDate == null) {
      return false;
    }
    return _dateOnly(currentDate).difference(_dateOnly(previousDate)).inDays ==
        1;
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _dateAtMidnight(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _StreakFreezeResult {
  const _StreakFreezeResult({
    required this.completedDates,
    required this.freezesRemaining,
  });

  final List<String> completedDates;
  final int freezesRemaining;
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
