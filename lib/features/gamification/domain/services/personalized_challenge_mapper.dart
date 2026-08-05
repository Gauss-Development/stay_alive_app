import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

/// Maps a validated AI challenge draft into a [GamificationChallenge] with live progress.
abstract final class PersonalizedChallengeMapper {
  static GamificationChallenge toChallenge({
    required PersonalizedChallengeDraft draft,
    required String dateKey,
    DailyLog? todayLog,
  }) {
    final ChallengeType type = _parseType(draft.challengeType);
    return GamificationChallenge(
      id: 'ai_daily_$dateKey',
      type: type,
      title: draft.title,
      description: draft.description,
      target: draft.target,
      progress: _progress(
        type: type,
        todayLog: todayLog,
        categoryId: draft.categoryId,
      ),
      xpReward: draft.xpReward,
      dateKey: dateKey,
      categoryId: draft.categoryId,
      isPremiumOnly: true,
    );
  }

  static ChallengeType _parseType(String raw) {
    return switch (raw) {
      'closeCategories' => ChallengeType.closeCategories,
      'earlyLog' => ChallengeType.earlyLog,
      'completeCategory' => ChallengeType.completeCategory,
      'perfectDay' => ChallengeType.perfectDay,
      'perfectDaysInWeek' => ChallengeType.perfectDaysInWeek,
      'activeDaysInWeek' => ChallengeType.activeDaysInWeek,
      _ => ChallengeType.logServings,
    };
  }

  static int _progress({
    required ChallengeType type,
    required DailyLog? todayLog,
    required String? categoryId,
  }) {
    if (todayLog == null) {
      return 0;
    }
    return switch (type) {
      ChallengeType.closeCategories =>
        todayLog.items.where((DailyLogItem i) => i.isCompleted).length,
      ChallengeType.logServings => todayLog.totalCompleted,
      ChallengeType.earlyLog => todayLog.totalCompleted > 0 ? 1 : 0,
      ChallengeType.completeCategory => () {
          if (categoryId == null) {
            return todayLog.items.any((DailyLogItem i) => i.isCompleted)
                ? 1
                : 0;
          }
          for (final DailyLogItem item in todayLog.items) {
            if (item.categoryId == categoryId && item.isCompleted) {
              return 1;
            }
          }
          return 0;
        }(),
      ChallengeType.perfectDay => todayLog.isFullyCompleted ? 1 : 0,
      ChallengeType.perfectDaysInWeek || ChallengeType.activeDaysInWeek => 0,
    };
  }
}
