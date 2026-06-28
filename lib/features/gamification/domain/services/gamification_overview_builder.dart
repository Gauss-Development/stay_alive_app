import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';

class GamificationOverviewBuilder {
  const GamificationOverviewBuilder({GamificationEngine? engine})
      : _engine = engine ?? const GamificationEngine();

  final GamificationEngine _engine;

  GamificationOverview build({
    required String userId,
    required List<DailyLog> logs,
    required List<GamificationXpEvent> persistedEvents,
    DateTime? referenceDate,
    bool isPremium = false,
    int streakFreezesRemaining = 0,
    List<String> streakFreezeUsedDates = const <String>[],
  }) {
    final DateTime reference = referenceDate ?? DateTime.now();
    final String todayKey = _dateKey(reference);
    final DailyLog? todayLog = _logForDate(logs, todayKey);
    final String weekKey = _weekKey(reference);
    final List<DailyLog> weekLogs = _logsForWeek(logs, reference);

    UserGameProfile profile = _engine.reconcile(
      userId: userId,
      logs: logs,
      referenceDate: reference,
      isPremium: isPremium,
      streakFreezesRemaining: streakFreezesRemaining,
      streakFreezeUsedDates: streakFreezeUsedDates,
    );

    final GamificationChallenge dailyChallenge = buildDailyChallenge(
      userId: userId,
      dateKey: todayKey,
      todayLog: todayLog,
    );

    final GamificationChallenge weeklyChallenge = buildWeeklyChallenge(
      userId: userId,
      weekKey: weekKey,
      weekLogs: weekLogs,
      isPremium: isPremium,
    );

    final bool dailyChallengeRewarded = persistedEvents.any(
      (GamificationXpEvent event) =>
          event.eventType == 'challenge_completed' &&
          event.logDate == todayKey,
    );
    if (dailyChallenge.isCompleted && !dailyChallengeRewarded) {
      profile = _applyBonusXp(profile, dailyChallenge.xpReward);
    }

    final bool weeklyChallengeRewarded = persistedEvents.any(
      (GamificationXpEvent event) =>
          event.eventType == 'weekly_challenge_completed' &&
          event.logDate == weekKey,
    );
    if (weeklyChallenge.isCompleted &&
        !weeklyChallengeRewarded &&
        (!weeklyChallenge.isPremiumOnly || isPremium)) {
      profile = _applyBonusXp(profile, weeklyChallenge.xpReward);
    }

    final List<CategoryMastery> mastery = buildCategoryMastery(logs);
    final List<GamificationXpEvent> recentXpEvents =
        _mergeRecentEvents(persistedEvents);

    return GamificationOverview(
      profile: profile,
      dailyChallenge: dailyChallenge,
      weeklyChallenge: weeklyChallenge,
      categoryMastery: mastery,
      recentXpEvents: recentXpEvents,
      isPremium: isPremium,
      xpMultiplier:
          isPremium ? GamificationEngine.premiumXpMultiplier : 1,
    );
  }

  GamificationChallenge buildDailyChallenge({
    required String userId,
    required String dateKey,
    required DailyLog? todayLog,
  }) {
    final int seed = Object.hash(userId, dateKey);
    final int templateIndex = seed.abs() % _dailyTemplates.length;
    final _ChallengeTemplate template = _dailyTemplates[templateIndex];

    return switch (template.type) {
      ChallengeType.closeCategories => GamificationChallenge(
          id: 'daily_$dateKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: template.target,
          progress: _completedCategories(todayLog),
          xpReward: template.xpReward,
          dateKey: dateKey,
        ),
      ChallengeType.logServings => GamificationChallenge(
          id: 'daily_$dateKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: template.target,
          progress: todayLog?.totalCompleted ?? 0,
          xpReward: template.xpReward,
          dateKey: dateKey,
        ),
      ChallengeType.earlyLog => GamificationChallenge(
          id: 'daily_$dateKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: 1,
          progress: _hasEarlyLog(todayLog) ? 1 : 0,
          xpReward: template.xpReward,
          dateKey: dateKey,
        ),
      ChallengeType.completeCategory => _categoryChallenge(
          userId: userId,
          dateKey: dateKey,
          todayLog: todayLog,
          template: template,
        ),
      ChallengeType.perfectDay => GamificationChallenge(
          id: 'daily_$dateKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: 1,
          progress: todayLog != null && todayLog.isFullyCompleted ? 1 : 0,
          xpReward: template.xpReward,
          dateKey: dateKey,
        ),
      ChallengeType.perfectDaysInWeek ||
      ChallengeType.activeDaysInWeek =>
        throw StateError('Weekly templates cannot be used for daily challenges.'),
    };
  }

  GamificationChallenge buildWeeklyChallenge({
    required String userId,
    required String weekKey,
    required List<DailyLog> weekLogs,
    required bool isPremium,
  }) {
    final int seed = Object.hash(userId, weekKey, 'weekly');
    final int templateIndex = seed.abs() % _weeklyTemplates.length;
    final _ChallengeTemplate template = _weeklyTemplates[templateIndex];

    return switch (template.type) {
      ChallengeType.perfectDaysInWeek => GamificationChallenge(
          id: 'weekly_$weekKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: template.target,
          progress: _perfectDaysInWeek(weekLogs),
          xpReward: template.xpReward,
          dateKey: weekKey,
          period: ChallengePeriod.weekly,
          isPremiumOnly: template.isPremiumOnly,
        ),
      ChallengeType.logServings => GamificationChallenge(
          id: 'weekly_$weekKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: template.target,
          progress: _servingsInWeek(weekLogs),
          xpReward: template.xpReward,
          dateKey: weekKey,
          period: ChallengePeriod.weekly,
          isPremiumOnly: template.isPremiumOnly,
        ),
      ChallengeType.activeDaysInWeek => GamificationChallenge(
          id: 'weekly_$weekKey',
          type: template.type,
          title: template.title,
          description: template.description,
          target: template.target,
          progress: _activeDaysInWeek(weekLogs),
          xpReward: template.xpReward,
          dateKey: weekKey,
          period: ChallengePeriod.weekly,
          isPremiumOnly: template.isPremiumOnly,
        ),
      ChallengeType.closeCategories ||
      ChallengeType.earlyLog ||
      ChallengeType.completeCategory ||
      ChallengeType.perfectDay =>
        throw StateError('Daily templates cannot be used for weekly challenges.'),
    };
  }

  GamificationChallenge _categoryChallenge({
    required String userId,
    required String dateKey,
    required DailyLog? todayLog,
    required _ChallengeTemplate template,
  }) {
    final List<String> categoryIds = _categoryPool;
    final int categoryIndex =
        Object.hash(userId, dateKey, 'category').abs() % categoryIds.length;
    final String categoryId = categoryIds[categoryIndex];
    DailyLogItem? item;
    if (todayLog != null) {
      for (final DailyLogItem candidate in todayLog.items) {
        if (candidate.categoryId == categoryId) {
          item = candidate;
          break;
        }
      }
    }

    final String title = item?.title ?? _titleForCategory(categoryId);
    return GamificationChallenge(
      id: 'daily_$dateKey',
      type: template.type,
      title: 'Complete $title',
      description: 'Finish the $title category today.',
      target: 1,
      progress: item != null && item.isCompleted ? 1 : 0,
      xpReward: template.xpReward,
      dateKey: dateKey,
      categoryId: categoryId,
    );
  }

  List<CategoryMastery> buildCategoryMastery(List<DailyLog> logs) {
    final Map<String, _MasteryAccumulator> totals =
        <String, _MasteryAccumulator>{};

    for (final DailyLog log in logs) {
      for (final DailyLogItem item in log.items) {
        final int capped = item.completedCount > item.targetCount
            ? item.targetCount
            : item.completedCount;
        if (capped <= 0) {
          continue;
        }
        totals.putIfAbsent(
          item.categoryId,
          () => _MasteryAccumulator(
            categoryId: item.categoryId,
            title: item.title,
            iconKey: item.category.iconKey,
          ),
        );
        totals[item.categoryId]!.servings += capped;
      }
    }

    final List<CategoryMastery> mastery = totals.values
        .map((_MasteryAccumulator value) {
          final MasteryTier tier =
              CategoryMastery.tierForServings(value.servings);
          return CategoryMastery(
            categoryId: value.categoryId,
            title: value.title,
            iconKey: value.iconKey,
            totalServings: value.servings,
            tier: tier,
            nextTierThreshold:
                CategoryMastery.nextThresholdForServings(value.servings),
          );
        })
        .toList(growable: false)
      ..sort(
        (CategoryMastery a, CategoryMastery b) =>
            b.totalServings.compareTo(a.totalServings),
      );

    return mastery;
  }

  UserGameProfile _applyBonusXp(UserGameProfile profile, int bonusXp) {
    final int totalXp = profile.totalXp + bonusXp;
    return profile.copyWith(
      totalXp: totalXp,
      currentLevel: GameLevelTable.forXp(totalXp),
    );
  }

  List<GamificationXpEvent> _mergeRecentEvents(
    List<GamificationXpEvent> persistedEvents,
  ) {
    final List<GamificationXpEvent> sorted =
        List<GamificationXpEvent>.of(persistedEvents)
          ..sort(
            (GamificationXpEvent a, GamificationXpEvent b) =>
                b.createdAt.compareTo(a.createdAt),
          );
    return sorted.take(30).toList(growable: false);
  }

  List<DailyLog> _logsForWeek(List<DailyLog> logs, DateTime reference) {
    final DateTime weekStart = _weekStart(reference);
    final String weekStartKey = _dateKey(weekStart);
    return logs
        .where((DailyLog log) => log.dateKey.compareTo(weekStartKey) >= 0)
        .toList(growable: false);
  }

  DateTime _weekStart(DateTime date) {
    return _dateOnly(date).subtract(Duration(days: date.weekday - 1));
  }

  String _weekKey(DateTime date) {
    return _dateKey(_weekStart(date));
  }

  int _perfectDaysInWeek(List<DailyLog> weekLogs) {
    return weekLogs.where((DailyLog log) => log.isFullyCompleted).length;
  }

  int _servingsInWeek(List<DailyLog> weekLogs) {
    return weekLogs.fold<int>(
      0,
      (int total, DailyLog log) => total + log.totalCompleted,
    );
  }

  int _activeDaysInWeek(List<DailyLog> weekLogs) {
    return weekLogs.where((DailyLog log) => log.totalCompleted > 0).length;
  }

  DailyLog? _logForDate(List<DailyLog> logs, String dateKey) {
    for (final DailyLog log in logs) {
      if (log.dateKey == dateKey) {
        return log;
      }
    }
    return null;
  }

  int _completedCategories(DailyLog? log) {
    if (log == null) {
      return 0;
    }
    return log.items.where((DailyLogItem item) => item.isCompleted).length;
  }

  bool _hasEarlyLog(DailyLog? log) {
    if (log == null) {
      return false;
    }
    for (final DailyLogItem item in log.items) {
      if (item.completedCount <= 0) {
        continue;
      }
      if (item.updatedAt.toLocal().hour < 12) {
        return true;
      }
    }
    return false;
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _titleForCategory(String categoryId) {
    return categoryId
        .split('_')
        .map(
          (String part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static const List<String> _categoryPool = <String>[
    'beans',
    'berries',
    'fruits',
    'greens',
    'whole_grains',
    'nuts',
  ];

  static const List<_ChallengeTemplate> _dailyTemplates = <_ChallengeTemplate>[
    _ChallengeTemplate(
      type: ChallengeType.closeCategories,
      title: 'Category Closer',
      description: 'Complete 3 Daily Dozen categories today.',
      target: 3,
      xpReward: 40,
    ),
    _ChallengeTemplate(
      type: ChallengeType.logServings,
      title: 'Servings Sprint',
      description: 'Log 8 servings today.',
      target: 8,
      xpReward: 35,
    ),
    _ChallengeTemplate(
      type: ChallengeType.earlyLog,
      title: 'Morning Momentum',
      description: 'Log a serving before noon.',
      target: 1,
      xpReward: 30,
    ),
    _ChallengeTemplate(
      type: ChallengeType.completeCategory,
      title: 'Category Focus',
      description: 'Fully complete one category today.',
      target: 1,
      xpReward: 45,
    ),
    _ChallengeTemplate(
      type: ChallengeType.perfectDay,
      title: 'Perfect Day Push',
      description: 'Complete the full Daily Dozen today.',
      target: 1,
      xpReward: 60,
    ),
  ];

  static const List<_ChallengeTemplate> _weeklyTemplates = <_ChallengeTemplate>[
    _ChallengeTemplate(
      type: ChallengeType.perfectDaysInWeek,
      title: 'Weekly Perfectionist',
      description: 'Hit 3 perfect days this week.',
      target: 3,
      xpReward: 120,
      isPremiumOnly: false,
    ),
    _ChallengeTemplate(
      type: ChallengeType.logServings,
      title: 'Weekly Servings',
      description: 'Log 30 servings this week.',
      target: 30,
      xpReward: 100,
      isPremiumOnly: false,
    ),
    _ChallengeTemplate(
      type: ChallengeType.activeDaysInWeek,
      title: 'Consistency Crew',
      description: 'Stay active on 5 days this week.',
      target: 5,
      xpReward: 150,
      isPremiumOnly: true,
    ),
  ];
}

class _ChallengeTemplate {
  const _ChallengeTemplate({
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.xpReward,
    this.isPremiumOnly = false,
  });

  final ChallengeType type;
  final String title;
  final String description;
  final int target;
  final int xpReward;
  final bool isPremiumOnly;
}

class _MasteryAccumulator {
  _MasteryAccumulator({
    required this.categoryId,
    required this.title,
    required this.iconKey,
  });

  final String categoryId;
  final String title;
  final String iconKey;
  int servings = 0;
}
