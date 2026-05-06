import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_progress_model.dart';

void main() {
  group('GamificationProgressModel.fromDailyLogData', () {
    test('calculates XP, streaks, levels, and badges deterministically', () {
      final GamificationProgressModel progress =
          GamificationProgressModel.fromDailyLogData(
        userId: 'user_1',
        logs: <Map<String, dynamic>>[
          <String, dynamic>{
            'log_date': '2026-05-01',
            'total_completed': 24,
            'is_fully_completed': true,
          },
          <String, dynamic>{
            'log_date': '2026-05-02',
            'total_completed': 12,
            'is_fully_completed': false,
          },
          <String, dynamic>{
            'log_date': '2026-05-03',
            'total_completed': 24,
            'is_fully_completed': true,
          },
          <String, dynamic>{
            'log_date': '2026-05-04',
            'total_completed': 24,
            'is_fully_completed': true,
          },
        ],
      );

      expect(progress.userId, 'user_1');
      expect(progress.xp, 445);
      expect(progress.level, 5);
      expect(progress.currentLevelXp, 400);
      expect(progress.nextLevelXp, 500);
      expect(progress.bestStreak, 2);
      expect(progress.completedDays, 3);
      expect(progress.badges, containsAll(<String>['first_log', 'perfect_day']));
    });
  });
}
