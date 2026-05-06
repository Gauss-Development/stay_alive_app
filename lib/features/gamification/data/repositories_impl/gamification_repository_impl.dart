import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  const GamificationRepositoryImpl(this._remoteDataSource);

  final GamificationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<GamificationProgress>> getProgress() async {
    try {
      final GamificationProgress progress =
          await _remoteDataSource.fetchProgress();
      return Right<Failure, GamificationProgress>(progress);
    } catch (exception) {
      return Left<Failure, GamificationProgress>(
        mapExceptionToFailure(exception),
      );
    }
  }
}
