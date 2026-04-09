import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => <Object?>[];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.summary);

  final HistorySummary summary;

  @override
  List<Object?> get props => <Object?>[summary];
}

class HistoryError extends HistoryState {
  const HistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
