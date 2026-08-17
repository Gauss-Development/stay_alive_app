import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';

abstract class AnalyticsRepository {
  Future<Result<void>> trackEvent(AnalyticsEvent event);
}
