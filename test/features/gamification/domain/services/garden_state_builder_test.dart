import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/garden_state_builder.dart';

void main() {
  group('GardenStateBuilder', () {
    test('maps level 5 to bloom and computes today growth', () {
      final DateTime now = DateTime(2026, 8, 5);
      const TrackerCategory greens = TrackerCategory(
        id: 'greens',
        title: 'Greens',
        description: 'Greens',
        targetCount: 2,
        displayOrder: 1,
        iconKey: 'greens',
        isActive: true,
      );
      final DailyLog today = DailyLog(
        id: '1',
        userId: 'u1',
        logDate: now,
        items: <DailyLogItem>[
          DailyLogItem(
            id: 'i1',
            category: greens,
            completedCount: 1,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        totalCompleted: 1,
        totalTarget: 2,
        completionPercentage: 50,
        isFullyCompleted: false,
      );

      final UserGameProfile profile = UserGameProfile.empty().copyWith(
        userId: 'u1',
        totalXp: 7000,
        currentLevel: GameLevelTable.forXp(7000),
        activityStreak: 3,
        completedDates: const <String>['2026-08-04'],
      );

      final GardenState garden = const GardenStateBuilder().build(
        profile: profile,
        recentLogs: <DailyLog>[today],
        todayLog: today,
        referenceDate: now,
      );

      expect(garden.stage, GardenStage.bloom);
      expect(garden.todayGrowth, 0.5);
      expect(garden.wilting, isFalse);
    });

    group('mood', () {
      SproutMood moodAt(DateTime reference, {DailyLog? todayLog}) {
        return const GardenStateBuilder()
            .build(
              profile: UserGameProfile.empty().copyWith(userId: 'u1'),
              recentLogs: <DailyLog>[],
              todayLog: todayLog,
              referenceDate: reference,
            )
            .mood;
      }

      test('sleeps at night even when the day is finished', () {
        final DateTime night = DateTime(2026, 8, 5, 23);
        expect(
          moodAt(night, todayLog: logWith(night, completed: 2, target: 2)),
          SproutMood.sleeping,
        );
      });

      test('celebrates a completed day', () {
        final DateTime noon = DateTime(2026, 8, 5, 12);
        expect(
          moodAt(noon, todayLog: logWith(noon, completed: 2, target: 2)),
          SproutMood.celebrating,
        );
      });

      test('waits — never sulks — when the day is untouched', () {
        expect(moodAt(DateTime(2026, 8, 5, 12)), SproutMood.waiting);
      });

      test('is happy with partial progress', () {
        final DateTime noon = DateTime(2026, 8, 5, 12);
        expect(
          moodAt(noon, todayLog: logWith(noon, completed: 1, target: 2)),
          SproutMood.happy,
        );
      });
    });
  });
}

DailyLog logWith(DateTime date, {required int completed, required int target}) {
  const TrackerCategory greens = TrackerCategory(
    id: 'greens',
    title: 'Greens',
    description: 'Greens',
    targetCount: 2,
    displayOrder: 1,
    iconKey: 'greens',
    isActive: true,
  );
  return DailyLog(
    id: '1',
    userId: 'u1',
    logDate: date,
    items: <DailyLogItem>[
      DailyLogItem(
        id: 'i1',
        category: greens,
        completedCount: completed,
        createdAt: date,
        updatedAt: date,
      ),
    ],
    totalCompleted: completed,
    totalTarget: target,
    completionPercentage: target == 0 ? 0 : completed / target * 100,
    isFullyCompleted: completed >= target,
  );
}
