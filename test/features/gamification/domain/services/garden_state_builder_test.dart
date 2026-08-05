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
  });
}
