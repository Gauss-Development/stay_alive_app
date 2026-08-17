import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/decrement_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_completion_summary_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/increment_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/initialize_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/reset_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';

class _MockGetTodayLog extends Mock implements GetTodayLogUseCase {}

class _MockInitializeTodayLog extends Mock
    implements InitializeTodayLogUseCase {}

class _MockIncrement extends Mock implements IncrementCategoryProgressUseCase {}

class _MockDecrement extends Mock implements DecrementCategoryProgressUseCase {}

class _MockResetToday extends Mock implements ResetTodayLogUseCase {}

class _MockGetSummary extends Mock implements GetCompletionSummaryUseCase {}

class _SilentLogger implements AppLogger {
  @override
  void debug(String message, {Map<String, Object?>? data}) {}
  @override
  void info(String message, {Map<String, Object?>? data}) {}
  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {}
  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {}
}

DailyLog _log(int completed) => DailyLog(
  id: 'user_1_2026-06-01',
  userId: 'user_1',
  logDate: DateTime.parse('2026-06-01T00:00:00Z'),
  items: <DailyLogItem>[
    DailyLogItem(
      id: 'item_beans',
      category: const TrackerCategory(
        id: 'beans',
        title: 'Beans',
        description: '',
        targetCount: 3,
        displayOrder: 1,
        iconKey: 'beans',
        isActive: true,
      ),
      completedCount: completed,
      createdAt: DateTime.parse('2026-06-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-01T00:00:00Z'),
    ),
  ],
  totalCompleted: completed,
  totalTarget: 3,
  completionPercentage: completed / 3 * 100,
  isFullyCompleted: completed >= 3,
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const IncrementCategoryProgressParams(categoryId: 'beans'),
    );
    registerFallbackValue(_log(0));
  });

  test('rapid taps are serialised so no serving is lost', () async {
    final _MockIncrement increment = _MockIncrement();
    final _MockGetSummary summary = _MockGetSummary();

    // Models the real read-modify-write: each call reads the shared counter,
    // waits for a round-trip, then writes back. Without serialisation the
    // second tap reads the pre-increment value and one serving disappears.
    int serverCount = 0;
    bool overlapped = false;
    int inFlight = 0;

    when(() => increment(any())).thenAnswer((_) async {
      inFlight++;
      if (inFlight > 1) {
        overlapped = true;
      }
      final int read = serverCount;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      serverCount = read + 1;
      inFlight--;
      return Right<Failure, DailyLog>(_log(serverCount));
    });

    when(() => summary(any())).thenAnswer(
      (_) => Right<Failure, CompletionSummary>(
        const CompletionSummary(
          totalCompleted: 0,
          totalTarget: 3,
          completionPercentage: 0,
          isFullyCompleted: false,
        ),
      ),
    );

    final DailyTrackerCubit cubit = DailyTrackerCubit(
      getTodayLogUseCase: _MockGetTodayLog(),
      initializeTodayLogUseCase: _MockInitializeTodayLog(),
      incrementCategoryProgressUseCase: increment,
      decrementCategoryProgressUseCase: _MockDecrement(),
      resetTodayLogUseCase: _MockResetToday(),
      getCompletionSummaryUseCase: summary,
      logger: _SilentLogger(),
    );

    // Three taps fired without awaiting — exactly what a user does.
    await Future.wait<void>(<Future<void>>[
      cubit.increment('beans'),
      cubit.increment('beans'),
      cubit.increment('beans'),
    ]);

    expect(overlapped, isFalse, reason: 'mutations must not overlap');
    expect(
      serverCount,
      3,
      reason: 'three taps must record three servings, not fewer',
    );

    await cubit.close();
  });
}
