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
  }) {
    final DateTime reference = referenceDate ?? DateTime.now();
    final String todayKey = _dateKey(reference);
    final DailyLog? todayLog = _logForDate(logs, todayKey);

    UserGameProfile profile = _engine.reconcile(
      userId: userId,
      logs: logs,
      referenceDate: reference,
    );

    final GamificationChallenge dailyChallenge = buildDailyChallenge(
      userId: userId,
      dateKey: todayKey,
      todayLog: todayLog,
    );

    final bool challengeAlreadyRewarded = persistedEvents.any(
      (GamificationXpEvent event) =>
          event.eventType == 'challenge_completed' &&
          event.logDate == todayKey,
    );

    if (dailyChallenge.isCompleted && !challengeAlreadyRewarded) {
      profile = _applyBonusXp(profile, dailyChallenge.xpReward);
    }

    final List<CategoryMastery> mastery = buildCategoryMastery(logs);
    final List<GamificationXpEvent> recentXpEvents =
        _mergeRecentEvents(persistedEvents);

    return GamificationOverview(
      profile: profile,
      dailyChallenge: dailyChallenge,
      categoryMastery: mastery,
      recentXpEvents: recentXpEvents,
    );
  }

  GamificationChallenge buildDailyChallenge({
    required String userId,
    required String dateKey,
    required DailyLog? todayLog,
  }) {
    final int seed = Object.hash(userId, dateKey);
    final int templateIndex = seed.abs() % _templates.length;
    final _ChallengeTemplate template = _templates[templateIndex];

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

  static const List<_ChallengeTemplate> _templates = <_ChallengeTemplate>[
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
}

class _ChallengeTemplate {
  const _ChallengeTemplate({
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.xpReward,
  });

  final ChallengeType type;
  final String title;
  final String description;
  final int target;
  final int xpReward;
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
