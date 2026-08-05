import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

class ReconcileGamificationParams extends Equatable {
  const ReconcileGamificationParams({
    required this.isPremium,
    this.personalizedDailyDraft,
  });

  final bool isPremium;
  final PersonalizedChallengeDraft? personalizedDailyDraft;

  @override
  List<Object?> get props => <Object?>[isPremium, personalizedDailyDraft];
}

class ReconcileGamificationTodayParams extends Equatable {
  const ReconcileGamificationTodayParams({
    required this.todayLog,
    required this.isPremium,
    this.personalizedDailyDraft,
  });

  final DailyLog todayLog;
  final bool isPremium;
  final PersonalizedChallengeDraft? personalizedDailyDraft;

  @override
  List<Object?> get props =>
      <Object?>[todayLog, isPremium, personalizedDailyDraft];
}
