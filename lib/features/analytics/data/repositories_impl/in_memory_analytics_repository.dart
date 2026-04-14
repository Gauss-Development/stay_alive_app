import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';
import 'package:stay_alive/features/analytics/domain/repositories/analytics_repository.dart';

class InMemoryAnalyticsRepository implements AnalyticsRepository {
  final List<AnalyticsEvent> _events = <AnalyticsEvent>[];

  @override
  Future<Result<void>> trackEvent(AnalyticsEvent event) async {
    _events.add(event);
    return const Right<Failure, void>(null);
  }
}
