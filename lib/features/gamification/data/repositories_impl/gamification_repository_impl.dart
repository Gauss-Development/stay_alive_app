import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/supabase_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  const GamificationRepositoryImpl(this._remoteDataSource);

  final GamificationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<GamificationOverview>> reconcileOverview({
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  }) async {
    try {
      final GamificationOverview overview = await _remoteDataSource
          .reconcileOverview(
            isPremium: isPremium,
            personalizedDailyDraft: personalizedDailyDraft,
          );
      return Right<Failure, GamificationOverview>(overview);
    } catch (exception) {
      return Left<Failure, GamificationOverview>(
        mapExceptionToFailure(exception),
      );
    }
  }

  @override
  Future<Result<GamificationOverview>> reconcileTodayOverview({
    required DailyLog todayLog,
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  }) async {
    try {
      final GamificationOverview overview = await _remoteDataSource
          .reconcileTodayOverview(
            todayLog: todayLog,
            isPremium: isPremium,
            personalizedDailyDraft: personalizedDailyDraft,
          );
      return Right<Failure, GamificationOverview>(overview);
    } catch (exception) {
      return Left<Failure, GamificationOverview>(
        mapExceptionToFailure(exception),
      );
    }
  }
}
