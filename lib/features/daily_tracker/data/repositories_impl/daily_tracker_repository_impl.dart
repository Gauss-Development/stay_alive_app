import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/daily_tracker/data/datasources/daily_tracker_remote_data_source.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';

class DailyTrackerRepositoryImpl implements DailyTrackerRepository {
  DailyTrackerRepositoryImpl(this._remoteDataSource);

  final DailyTrackerRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DailyLog>> getTodayLog() async {
    try {
      final DailyLogModel? log = await _remoteDataSource.getLogByDate(
        _todayDateKey(),
      );
      if (log == null) {
        return const Left<Failure, DailyLog>(
          DatabaseFailure('No log exists for today.'),
        );
      }
      return Right<Failure, DailyLog>(log);
    } catch (exception) {
      return Left<Failure, DailyLog>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<DailyLog>> initializeTodayLog() async {
    try {
      final DailyLogModel log = await _remoteDataSource.initializeLog(
        _todayDateKey(),
      );
      return Right<Failure, DailyLog>(log);
    } catch (exception) {
      return Left<Failure, DailyLog>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<DailyLog>> incrementCategoryProgress({
    required String categoryId,
  }) async {
    try {
      final DailyLogModel log = await _remoteDataSource.updateCategoryProgress(
        dateKey: _todayDateKey(),
        categoryId: categoryId,
        delta: 1,
      );
      return Right<Failure, DailyLog>(log);
    } catch (exception) {
      return Left<Failure, DailyLog>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<DailyLog>> decrementCategoryProgress({
    required String categoryId,
  }) async {
    try {
      final DailyLogModel log = await _remoteDataSource.updateCategoryProgress(
        dateKey: _todayDateKey(),
        categoryId: categoryId,
        delta: -1,
      );
      return Right<Failure, DailyLog>(log);
    } catch (exception) {
      return Left<Failure, DailyLog>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<DailyLog>> resetTodayLog() async {
    try {
      final DailyLogModel log = await _remoteDataSource.resetLog(
        _todayDateKey(),
      );
      return Right<Failure, DailyLog>(log);
    } catch (exception) {
      return Left<Failure, DailyLog>(mapExceptionToFailure(exception));
    }
  }

  String _todayDateKey() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
