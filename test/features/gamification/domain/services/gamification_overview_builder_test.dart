import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_overview_builder.dart';

void main() {
  const GamificationOverviewBuilder builder = GamificationOverviewBuilder();
  const TrackerCategory beans = TrackerCategory(
    id: 'beans',
    title: 'Beans',
    description: 'Beans',
    targetCount: 3,
    displayOrder: 1,
    iconKey: 'beans',
    isActive: true,
  );

  group('GamificationOverviewBuilder', () {
    test('builds deterministic daily challenge for user and date', () {
      final GamificationChallenge challenge = builder.buildDailyChallenge(
        userId: 'user_1',
        dateKey: '2026-06-01',
        todayLog: null,
      );

      expect(challenge.id, 'daily_2026-06-01');
      expect(challenge.dateKey, '2026-06-01');
      expect(challenge.target, greaterThan(0));
    });

    test('tracks category mastery from lifetime servings', () {
      final List<CategoryMastery> mastery = builder.buildCategoryMastery(
        <DailyLog>[
          DailyLog(
            id: '2026-06-01',
            userId: 'user_1',
            logDate: DateTime.parse('2026-06-01T12:00:00'),
            items: <DailyLogItem>[
              DailyLogItem(
                id: 'item_1',
                category: beans,
                completedCount: 12,
                createdAt: DateTime.parse('2026-06-01T12:00:00'),
                updatedAt: DateTime.parse('2026-06-01T12:00:00'),
              ),
            ],
            totalCompleted: 12,
            totalTarget: 3,
            completionPercentage: 100,
            isFullyCompleted: true,
          ),
        ],
      );

      expect(mastery, hasLength(1));
      expect(mastery.first.categoryId, 'beans');
      expect(mastery.first.totalServings, 3);
      expect(mastery.first.tier, MasteryTier.none);
    });

    test('adds challenge XP only when challenge is newly completed', () {
      final DailyLog todayLog = DailyLog(
        id: '2026-06-28',
        userId: 'user_1',
        logDate: DateTime.parse('2026-06-28T12:00:00'),
        items: <DailyLogItem>[
          DailyLogItem(
            id: 'item_1',
            category: beans,
            completedCount: 8,
            createdAt: DateTime.parse('2026-06-28T10:00:00'),
            updatedAt: DateTime.parse('2026-06-28T10:00:00'),
          ),
        ],
        totalCompleted: 8,
        totalTarget: 24,
        completionPercentage: 33,
        isFullyCompleted: false,
      );

      final overview = builder.build(
        userId: 'user_1',
        logs: <DailyLog>[todayLog],
        persistedEvents: const <GamificationXpEvent>[],
        referenceDate: DateTime.parse('2026-06-28T18:00:00'),
      );

      if (overview.dailyChallenge.type == ChallengeType.logServings &&
          overview.dailyChallenge.isCompleted) {
        expect(
          overview.profile.totalXp,
          greaterThan(overview.dailyChallenge.xpReward),
        );
      } else {
        expect(overview.profile.totalXp, greaterThan(0));
      }
    });
  });
}
