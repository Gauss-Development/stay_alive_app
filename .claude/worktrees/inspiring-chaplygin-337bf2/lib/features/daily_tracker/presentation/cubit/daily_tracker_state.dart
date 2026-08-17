import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';

enum DailyTrackerStatus {
  initial,
  loading,
  loaded,
  error,
}

class DailyTrackerState extends Equatable {
  const DailyTrackerState({
    required this.status,
    this.log,
    this.summary,
    this.errorMessage,
  });

  const DailyTrackerState.initial()
      : status = DailyTrackerStatus.initial,
        log = null,
        summary = null,
        errorMessage = null;

  final DailyTrackerStatus status;
  final DailyLog? log;
  final CompletionSummary? summary;
  final String? errorMessage;

  DailyTrackerState copyWith({
    DailyTrackerStatus? status,
    DailyLog? log,
    CompletionSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DailyTrackerState(
      status: status ?? this.status,
      log: log ?? this.log,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, log, summary, errorMessage];
}
