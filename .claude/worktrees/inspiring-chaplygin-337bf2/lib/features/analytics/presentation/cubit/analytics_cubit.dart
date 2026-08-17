import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';
import 'package:stay_alive/features/analytics/domain/usecases/track_event_usecase.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this._trackEventUseCase) : super(const AnalyticsInitial());

  final TrackEventUseCase _trackEventUseCase;

  Future<void> track({
    required String eventName,
    String? screenName,
    Map<String, dynamic>? metadata,
  }) async {
    emit(const AnalyticsLoading());
    final result = await _trackEventUseCase(
      TrackEventParams(
        event: AnalyticsEvent(
          name: eventName,
          screenName: screenName,
          metadata: metadata ?? <String, dynamic>{},
          createdAt: DateTime.now().toUtc(),
        ),
      ),
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (_) => emit(
        AnalyticsTracked(
          AnalyticsEvent(
            name: eventName,
            screenName: screenName,
            metadata: metadata ?? <String, dynamic>{},
            createdAt: DateTime.now().toUtc(),
          ),
        ),
      ),
    );
  }
}
