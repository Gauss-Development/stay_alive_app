import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => <Object?>[];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsTracked extends AnalyticsState {
  const AnalyticsTracked(this.event);

  final AnalyticsEvent event;

  @override
  List<Object?> get props => <Object?>[event];
}

class AnalyticsError extends AnalyticsState {
  const AnalyticsError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
