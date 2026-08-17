import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';

void main() {
  const GamificationEngine engine = GamificationEngine();
  const TrackerCategory beans = TrackerCategory(
    id: 'beans',
    title: 'Beans',
    description: 'Beans',
    targetCount: 3,
    displayOrder: 1,
    iconKey: 'beans',
    isActive: true,
  );

  DailyLog logForDate({
    required String dateKey,
    required int completed,
    required int target,
    bool fullyCompleted = false,
    List<DailyLogItem>? items,
  }) {
    final DateTime date = DateTime.parse('${dateKey}T12:00:00');
    return DailyLog(
      id: dateKey,
      userId: 'user_1',
      logDate: date,
      items: items ??
          <DailyLogItem>[
            DailyLogItem(
              id: 'item_$dateKey',
              category: beans,
              completedCount: completed,
              createdAt: date,
              updatedAt: date,
            ),
          ],
      totalCompleted: completed,
      totalTarget: target,
      completionPercentage: target == 0 ? 0 : (completed / target) * 100,
      isFullyCompleted: fullyCompleted,
    );
  }

  group('GamificationEngine', () {
    test('awards serving, category, and perfect day XP', () {
      final UserGameProfile profile = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[
          logForDate(
            dateKey: '2026-05-01',
            completed: 3,
            target: 3,
            fullyCompleted: true,
            items: <DailyLogItem>[
              DailyLogItem(
                id: 'item_1',
                category: beans,
                completedCount: 3,
                createdAt: DateTime.parse('2026-05-01T08:00:00'),
                updatedAt: DateTime.parse('2026-05-01T08:00:00'),
              ),
            ],
          ),
        ],
        referenceDate: DateTime.parse('2026-05-01T20:00:00'),
      );

      expect(profile.totalXp, greaterThan(0));
      expect(profile.currentLevel.level, 1);
      expect(profile.completedDates, <String>['2026-05-01']);
      expect(
        profile.earnedBadges.map((EarnedBadge badge) => badge.id),
        containsAll(<BadgeId>[BadgeId.firstStep, BadgeId.perfectDay]),
      );
    });

    test('resets current perfect streak when last perfect day is too old', () {
      final UserGameProfile profile = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[
          logForDate(
            dateKey: '2026-05-01',
            completed: 3,
            target: 3,
            fullyCompleted: true,
          ),
          logForDate(
            dateKey: '2026-05-02',
            completed: 3,
            target: 3,
            fullyCompleted: true,
          ),
        ],
        referenceDate: DateTime.parse('2026-05-05T12:00:00'),
      );

      expect(profile.longestStreak, 2);
      expect(profile.currentStreak, 0);
    });

    test('keeps current perfect streak when last perfect day is today', () {
      final UserGameProfile profile = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[
          logForDate(
            dateKey: '2026-05-03',
            completed: 3,
            target: 3,
            fullyCompleted: true,
          ),
          logForDate(
            dateKey: '2026-05-04',
            completed: 3,
            target: 3,
            fullyCompleted: true,
          ),
        ],
        referenceDate: DateTime.parse('2026-05-04T20:00:00'),
      );

      expect(profile.currentStreak, 2);
      expect(profile.activityStreak, 2);
    });

    test('awards patron badge and premium freeze allowance', () {
      final UserGameProfile profile = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[
          logForDate(
            dateKey: '2026-05-01',
            completed: 1,
            target: 3,
          ),
        ],
        referenceDate: DateTime.parse('2026-05-01T20:00:00'),
        isPremium: true,
      );

      expect(
        profile.earnedBadges.map((EarnedBadge badge) => badge.id),
        contains(BadgeId.patron),
      );
      expect(profile.streakFreezesRemaining, 2);
    });

    test('diffProfiles emits level up and badge unlock effects', () {
      const UserGameProfile previous = UserGameProfile(
        userId: 'user_1',
        totalXp: 400,
        currentLevel: GameLevel(
          level: 1,
          title: 'Seedling',
          xpRequired: 0,
          xpForNext: 500,
        ),
        currentStreak: 0,
        longestStreak: 0,
        activityStreak: 0,
        completedDates: <String>[],
        earlyLogDates: <String>[],
        earnedBadges: <EarnedBadge>[],
        totalCategoriesCompleted: 0,
      );
      final UserGameProfile next = UserGameProfile(
        userId: 'user_1',
        totalXp: 650,
        currentLevel: const GameLevel(
          level: 2,
          title: 'Sprout',
          xpRequired: 500,
          xpForNext: 1500,
        ),
        currentStreak: 1,
        longestStreak: 1,
        activityStreak: 1,
        completedDates: <String>['2026-05-01'],
        earlyLogDates: <String>[],
        earnedBadges: <EarnedBadge>[
          EarnedBadge(
            id: BadgeId.firstStep,
            earnedAt: DateTime.utc(2026, 5, 1),
          ),
        ],
        totalCategoriesCompleted: 1,
      );

      final effects = engine.diffProfiles(previous, next);
      expect(effects, hasLength(2));
    });
  });
}
