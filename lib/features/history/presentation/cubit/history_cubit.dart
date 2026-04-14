import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/history/domain/usecases/get_history_summary_usecase.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required GetHistorySummaryUseCase getHistorySummaryUseCase,
  })  : _getHistorySummaryUseCase = getHistorySummaryUseCase,
        super(const HistoryState.initial());

  final GetHistorySummaryUseCase _getHistorySummaryUseCase;

  Future<void> load() async {
    emit(const HistoryState.loading());
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 29));
    final result = await _getHistorySummaryUseCase(
      GetHistorySummaryParams(
        startDate: startDate,
        endDate: now,
      ),
    );
    result.fold(
      (failure) => emit(HistoryState.error(failure.message)),
      (summary) => emit(HistoryState.loaded(summary)),
    );
  }
}
