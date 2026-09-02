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

    test('awards rainbow plate once all 12 categories completed', () {
      TrackerCategory categoryFor(int index) => TrackerCategory(
        id: 'cat_$index',
        title: 'Category $index',
        description: 'Category $index',
        targetCount: 1,
        displayOrder: index,
        iconKey: 'beans',
        isActive: true,
      );

      List<DailyLogItem> itemsFor(String dateKey, int from, int to) {
        final DateTime date = DateTime.parse('${dateKey}T12:00:00');
        return <DailyLogItem>[
          for (int index = from; index <= to; index += 1)
            DailyLogItem(
              id: 'item_${dateKey}_$index',
              category: categoryFor(index),
              completedCount: 1,
              createdAt: date,
              updatedAt: date,
            ),
        ];
      }

      // 11 distinct categories across two days — not enough.
      final UserGameProfile partial = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[
          logForDate(
            dateKey: '2026-05-01',
            completed: 6,
            target: 6,
            items: itemsFor('2026-05-01', 1, 6),
          ),
          logForDate(
            dateKey: '2026-05-02',
            completed: 5,
            target: 5,
            items: itemsFor('2026-05-02', 7, 11),
          ),
        ],
        referenceDate: DateTime.parse('2026-05-02T20:00:00'),
      );
      expect(
        partial.earnedBadges.map((EarnedBadge badge) => badge.id),
        isNot(contains(BadgeId.rainbowPlate)),
      );

      // The 12th category on a later day completes the set cumulatively.
      final UserGameProfile full = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[
          logForDate(
            dateKey: '2026-05-01',
            completed: 6,
            target: 6,
            items: itemsFor('2026-05-01', 1, 6),
          ),
          logForDate(
            dateKey: '2026-05-02',
            completed: 5,
            target: 5,
            items: itemsFor('2026-05-02', 7, 11),
          ),
          logForDate(
            dateKey: '2026-05-03',
            completed: 1,
            target: 1,
            items: itemsFor('2026-05-03', 12, 12),
          ),
        ],
        referenceDate: DateTime.parse('2026-05-03T20:00:00'),
      );
      expect(
        full.earnedBadges.map((EarnedBadge badge) => badge.id),
        contains(BadgeId.rainbowPlate),
      );
      expect(full.totalCategoriesCompleted, 12);
    });

    test('awards night owl after logging past 9 PM on 5 days', () {
      DailyLog lateLogFor(String dateKey) {
        final DateTime lateEvening = DateTime.parse('${dateKey}T22:15:00');
        return logForDate(
          dateKey: dateKey,
          completed: 1,
          target: 3,
          items: <DailyLogItem>[
            DailyLogItem(
              id: 'item_$dateKey',
              category: beans,
              completedCount: 1,
              createdAt: lateEvening,
              updatedAt: lateEvening,
            ),
          ],
        );
      }

      final List<DailyLog> fourLateDays = <DailyLog>[
        for (int day = 1; day <= 4; day += 1) lateLogFor('2026-05-0$day'),
      ];
      final UserGameProfile notYet = engine.reconcile(
        userId: 'user_1',
        logs: fourLateDays,
        referenceDate: DateTime.parse('2026-05-04T23:00:00'),
      );
      expect(
        notYet.earnedBadges.map((EarnedBadge badge) => badge.id),
        isNot(contains(BadgeId.nightOwl)),
      );

      final UserGameProfile earned = engine.reconcile(
        userId: 'user_1',
        logs: <DailyLog>[...fourLateDays, lateLogFor('2026-05-05')],
        referenceDate: DateTime.parse('2026-05-05T23:00:00'),
      );
      expect(
        earned.earnedBadges.map((EarnedBadge badge) => badge.id),
        contains(BadgeId.nightOwl),
      );
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
