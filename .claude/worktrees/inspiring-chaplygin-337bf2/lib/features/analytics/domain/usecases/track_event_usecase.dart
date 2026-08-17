import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';
import 'package:stay_alive/features/analytics/domain/repositories/analytics_repository.dart';

class TrackEventUseCase implements UseCase<void, TrackEventParams> {
  const TrackEventUseCase(this._repository);

  final AnalyticsRepository _repository;

  @override
  Future<Result<void>> call(TrackEventParams params) {
    return _repository.trackEvent(params.event);
  }
}

class TrackEventParams extends Equatable {
  const TrackEventParams({
    required this.event,
  });

  final AnalyticsEvent event;

  @override
  List<Object?> get props => <Object?>[event];
}
