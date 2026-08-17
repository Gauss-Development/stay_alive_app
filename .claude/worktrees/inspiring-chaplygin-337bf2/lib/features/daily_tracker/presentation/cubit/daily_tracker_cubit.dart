import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/decrement_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_completion_summary_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/increment_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/initialize_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/reset_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';

class DailyTrackerCubit extends Cubit<DailyTrackerState> {
  DailyTrackerCubit({
    required GetTodayLogUseCase getTodayLogUseCase,
    required InitializeTodayLogUseCase initializeTodayLogUseCase,
    required IncrementCategoryProgressUseCase incrementCategoryProgressUseCase,
    required DecrementCategoryProgressUseCase decrementCategoryProgressUseCase,
    required ResetTodayLogUseCase resetTodayLogUseCase,
    required GetCompletionSummaryUseCase getCompletionSummaryUseCase,
    required AppLogger logger,
  }) : _getTodayLogUseCase = getTodayLogUseCase,
       _initializeTodayLogUseCase = initializeTodayLogUseCase,
       _incrementCategoryProgressUseCase = incrementCategoryProgressUseCase,
       _decrementCategoryProgressUseCase = decrementCategoryProgressUseCase,
       _resetTodayLogUseCase = resetTodayLogUseCase,
       _getCompletionSummaryUseCase = getCompletionSummaryUseCase,
       _logger = logger,
       super(const DailyTrackerState.initial());

  final GetTodayLogUseCase _getTodayLogUseCase;
  final InitializeTodayLogUseCase _initializeTodayLogUseCase;
  final IncrementCategoryProgressUseCase _incrementCategoryProgressUseCase;
  final DecrementCategoryProgressUseCase _decrementCategoryProgressUseCase;
  final ResetTodayLogUseCase _resetTodayLogUseCase;
  final GetCompletionSummaryUseCase _getCompletionSummaryUseCase;
  final AppLogger _logger;

  Future<void> loadToday() async {
    final bool shouldShowLoader = state.log == null;
    if (shouldShowLoader) {
      emit(
        state.copyWith(status: DailyTrackerStatus.loading, clearError: true),
      );
    } else if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }

    final result = await _getTodayLogUseCase(const NoParams());
    await result.fold(
      (failure) async {
        _logger.warning(
          'Today log not found, initializing one',
          data: <String, Object?>{'reason': failure.message},
        );
        await _initializeAndEmit();
      },
      (log) async {
        _emitLoadedWithSummary(log);
      },
    );
  }

  Future<void> increment(String categoryId) async {
    await _mutateWithLoading(
      operation: () => _incrementCategoryProgressUseCase(
        IncrementCategoryProgressParams(categoryId: categoryId),
      ),
      operationName: 'increment',
      categoryId: categoryId,
    );
  }

  Future<void> decrement(String categoryId) async {
    await _mutateWithLoading(
      operation: () => _decrementCategoryProgressUseCase(
        DecrementCategoryProgressParams(categoryId: categoryId),
      ),
      operationName: 'decrement',
      categoryId: categoryId,
    );
  }

  Future<void> resetToday() async {
    final bool shouldShowLoader = state.log == null;
    if (shouldShowLoader) {
      emit(
        state.copyWith(status: DailyTrackerStatus.loading, clearError: true),
      );
    } else if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
    final result = await _resetTodayLogUseCase(const ResetTodayLogParams());
    result.fold(_emitError, _emitLoadedWithSummary);
  }

  Future<void> _initializeAndEmit() async {
    final result = await _initializeTodayLogUseCase(const NoParams());
    result.fold(_emitError, _emitLoadedWithSummary);
  }

  Future<void> _mutateWithLoading({
    required Future<Result<DailyLog>> Function() operation,
    required String operationName,
    required String categoryId,
  }) async {
    final bool shouldShowLoader = state.log == null;
    if (shouldShowLoader) {
      emit(
        state.copyWith(status: DailyTrackerStatus.loading, clearError: true),
      );
    } else if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
    final Result<DailyLog> result = await operation();
    result.fold((Failure failure) {
      _logger.error(
        'Daily tracker mutation failed',
        data: <String, Object?>{
          'operation': operationName,
          'categoryId': categoryId,
          'error': failure.message,
        },
      );
      _emitError(failure);
    }, (DailyLog log) => _emitLoadedWithSummary(log));
  }

  void _emitLoadedWithSummary(DailyLog log) {
    final Result<CompletionSummary> summaryResult =
        _getCompletionSummaryUseCase(log);
    summaryResult.fold(
      _emitError,
      (summary) => emit(
        state.copyWith(
          status: DailyTrackerStatus.loaded,
          log: log,
          summary: summary,
          clearError: true,
        ),
      ),
    );
  }

  void _emitError(Failure failure) {
    emit(
      state.copyWith(
        status: state.log == null
            ? DailyTrackerStatus.error
            : DailyTrackerStatus.loaded,
        errorMessage: failure.message,
      ),
    );
  }
}
