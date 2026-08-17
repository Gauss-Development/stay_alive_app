import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';
import 'package:stay_alive/features/history/domain/repositories/history_repository.dart';

class GetHistorySummaryUseCase
    implements UseCase<HistorySummary, GetHistorySummaryParams> {
  const GetHistorySummaryUseCase(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Result<HistorySummary>> call(GetHistorySummaryParams params) {
    return _repository.getHistorySummary(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetHistorySummaryParams extends Equatable {
  const GetHistorySummaryParams({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => <Object?>[startDate, endDate];
}
