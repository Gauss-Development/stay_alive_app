import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/services/garden_state_builder.dart';

/// Shared coach context from today's log + gamification overview.
abstract final class CoachContextBuilder {
  static CoachContextPayload build({
    required GamificationOverview? overview,
    DailyLog? todayLog,
    String? categoryId,
    String? userMessage,
    String? weekSummary,
  }) {
    final incomplete = todayLog?.items
            .where((DailyLogItem i) => !i.isCompleted)
            .map((DailyLogItem i) => i.categoryId)
            .toList() ??
        const <String>[];

    if (overview == null) {
      return CoachContextPayload(
        level: 1,
        levelTitle: 'Seedling',
        streak: 0,
        activityStreak: 0,
        todayCompleted: todayLog?.totalCompleted ?? 0,
        todayTarget: todayLog?.totalTarget ?? 0,
        incompleteCategories: incomplete,
        wilting: false,
        categoryId: categoryId,
        userMessage: userMessage,
        weekSummary: weekSummary,
      );
    }

    final GardenState garden = const GardenStateBuilder().build(
      profile: overview.profile,
      recentLogs: todayLog == null ? const <DailyLog>[] : <DailyLog>[todayLog],
      todayLog: todayLog,
    );

    return CoachContextPayload(
      level: overview.profile.currentLevel.level,
      levelTitle: overview.profile.currentLevel.title,
      streak: overview.profile.currentStreak,
      activityStreak: overview.profile.activityStreak,
      todayCompleted: todayLog?.totalCompleted ?? 0,
      todayTarget: todayLog?.totalTarget ?? 0,
      incompleteCategories: incomplete,
      wilting: garden.wilting,
      categoryId: categoryId,
      userMessage: userMessage,
      weekSummary: weekSummary,
    );
  }
}
