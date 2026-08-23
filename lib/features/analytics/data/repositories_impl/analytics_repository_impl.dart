import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/supabase_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';
import 'package:stay_alive/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._remoteDataSource);

  final AnalyticsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> trackEvent(AnalyticsEvent event) async {
    try {
      await _remoteDataSource.trackEvent(event);
      return const Right<Failure, void>(null);
    } catch (exception) {
      return Left<Failure, void>(mapExceptionToFailure(exception));
    }
  }
}
