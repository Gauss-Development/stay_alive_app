import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/decrement_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_completion_summary_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/increment_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/initialize_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/reset_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';

class _MockGetTodayLogUseCase extends Mock implements GetTodayLogUseCase {}

class _MockInitializeTodayLogUseCase extends Mock
    implements InitializeTodayLogUseCase {}

class _MockIncrementCategoryProgressUseCase extends Mock
    implements IncrementCategoryProgressUseCase {}

class _MockDecrementCategoryProgressUseCase extends Mock
    implements DecrementCategoryProgressUseCase {}

class _MockResetTodayLogUseCase extends Mock implements ResetTodayLogUseCase {}

class _MockGetCompletionSummaryUseCase extends Mock
    implements GetCompletionSummaryUseCase {}

class _MockAppLogger extends Mock implements AppLogger {}

DailyLog _buildDailyLog({required int completed}) {
  const TrackerCategory category = TrackerCategory(
    id: 'beans',
    title: 'Beans',
    description: 'Beans target',
    targetCount: 3,
    displayOrder: 1,
    iconKey: 'beans',
    isActive: true,
  );
  final DateTime now = DateTime(2026, 4, 9);
  return DailyLog(
    id: 'log-id',
    userId: 'user-id',
    logDate: now,
    items: <DailyLogItem>[
      DailyLogItem(
        id: 'item-id',
        category: category,
        completedCount: completed,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    totalCompleted: completed,
    totalTarget: 3,
    completionPercentage: (completed / 3) * 100,
    isFullyCompleted: completed >= 3,
  );
}

void main() {
  late _MockGetTodayLogUseCase mockGetTodayLogUseCase;
  late _MockInitializeTodayLogUseCase mockInitializeTodayLogUseCase;
  late _MockIncrementCategoryProgressUseCase
      mockIncrementCategoryProgressUseCase;
  late _MockDecrementCategoryProgressUseCase
      mockDecrementCategoryProgressUseCase;
  late _MockResetTodayLogUseCase mockResetTodayLogUseCase;
  late _MockGetCompletionSummaryUseCase mockGetCompletionSummaryUseCase;
  late _MockAppLogger mockAppLogger;

  late DailyTrackerCubit cubit;

  setUp(() {
    mockGetTodayLogUseCase = _MockGetTodayLogUseCase();
    mockInitializeTodayLogUseCase = _MockInitializeTodayLogUseCase();
    mockIncrementCategoryProgressUseCase =
        _MockIncrementCategoryProgressUseCase();
    mockDecrementCategoryProgressUseCase =
        _MockDecrementCategoryProgressUseCase();
    mockResetTodayLogUseCase = _MockResetTodayLogUseCase();
    mockGetCompletionSummaryUseCase = _MockGetCompletionSummaryUseCase();
    mockAppLogger = _MockAppLogger();

    final DailyLog log = _buildDailyLog(completed: 1);
    const CompletionSummary summary = CompletionSummary(
      totalCompleted: 1,
      totalTarget: 3,
      completionPercentage: 33.3,
      isFullyCompleted: false,
    );

    when(() => mockGetTodayLogUseCase.call(any()))
        .thenAnswer((_) async => Right<Failure, DailyLog>(log));
    when(() => mockInitializeTodayLogUseCase.call(any()))
        .thenAnswer((_) async => Right<Failure, DailyLog>(log));
    when(() => mockIncrementCategoryProgressUseCase.call(any()))
        .thenAnswer((_) async => Right<Failure, DailyLog>(log));
    when(() => mockDecrementCategoryProgressUseCase.call(any()))
        .thenAnswer((_) async => Right<Failure, DailyLog>(log));
    when(() => mockResetTodayLogUseCase.call(any()))
        .thenAnswer((_) async => Right<Failure, DailyLog>(log));
    when(() => mockGetCompletionSummaryUseCase.call(any())).thenReturn(
      const Right<Failure, CompletionSummary>(summary),
    );

    cubit = DailyTrackerCubit(
      getTodayLogUseCase: mockGetTodayLogUseCase,
      initializeTodayLogUseCase: mockInitializeTodayLogUseCase,
      incrementCategoryProgressUseCase: mockIncrementCategoryProgressUseCase,
      decrementCategoryProgressUseCase: mockDecrementCategoryProgressUseCase,
      resetTodayLogUseCase: mockResetTodayLogUseCase,
      getCompletionSummaryUseCase: mockGetCompletionSummaryUseCase,
      logger: mockAppLogger,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<DailyTrackerCubit, DailyTrackerState>(
    'emits [loading, loaded] when loadToday succeeds',
    build: () => cubit,
    act: (DailyTrackerCubit cubit) => cubit.loadToday(),
    expect: () => <Matcher>[
      isA<DailyTrackerState>().having(
        (DailyTrackerState state) => state.status,
        'status',
        DailyTrackerStatus.loading,
      ),
      isA<DailyTrackerState>().having(
        (DailyTrackerState state) => state.status,
        'status',
        DailyTrackerStatus.loaded,
      ),
    ],
  );

  blocTest<DailyTrackerCubit, DailyTrackerState>(
    'emits [loading, error] when summary usecase fails',
    build: () {
      when(() => mockGetCompletionSummaryUseCase.call(any())).thenReturn(
        const Left<Failure, CompletionSummary>(
          ValidationFailure('Invalid totals'),
        ),
      );
      return cubit;
    },
    act: (DailyTrackerCubit cubit) => cubit.loadToday(),
    expect: () => <Matcher>[
      isA<DailyTrackerState>().having(
        (DailyTrackerState state) => state.status,
        'status',
        DailyTrackerStatus.loading,
      ),
      isA<DailyTrackerState>()
          .having(
            (DailyTrackerState state) => state.status,
            'status',
            DailyTrackerStatus.error,
          )
          .having(
            (DailyTrackerState state) => state.errorMessage,
            'errorMessage',
            'Invalid totals',
          ),
    ],
  );
}
