import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

abstract class GamificationRepository {
  Future<Result<GamificationOverview>> reconcileOverview({
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  });

  Future<Result<GamificationOverview>> reconcileTodayOverview({
    required DailyLog todayLog,
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  });
}
