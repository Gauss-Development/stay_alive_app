import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  const GamificationRepositoryImpl(this._remoteDataSource);

  final GamificationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<UserGameProfile>> reconcileProgress() async {
    try {
      final UserGameProfile profile =
          await _remoteDataSource.reconcileProgress();
      return Right<Failure, UserGameProfile>(profile);
    } catch (exception) {
      return Left<Failure, UserGameProfile>(
        mapExceptionToFailure(exception),
      );
    }
  }
}
