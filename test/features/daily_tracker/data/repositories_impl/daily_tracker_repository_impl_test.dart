import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/daily_tracker/data/datasources/daily_tracker_remote_data_source.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/daily_tracker/data/repositories_impl/daily_tracker_repository_impl.dart';

class _MockDailyTrackerRemoteDataSource extends Mock
    implements DailyTrackerRemoteDataSource {}

void main() {
  late _MockDailyTrackerRemoteDataSource dataSource;
  late DailyTrackerRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDailyTrackerRemoteDataSource();
    repository = DailyTrackerRepositoryImpl(dataSource);
  });

  test('getTodayLog returns DatabaseFailure when no log exists', () async {
    when(() => dataSource.getLogByDate(any())).thenAnswer((_) async => null);

    final result = await repository.getTodayLog();

    expect(result.isLeft(), isTrue);
    result.fold(
      (Failure failure) => expect(failure, isA<DatabaseFailure>()),
      (_) => fail('Expected failure'),
    );
  });

  test('incrementCategoryProgress delegates positive delta', () async {
    final DailyLogModel log = _log();
    when(
      () => dataSource.updateCategoryProgress(
        dateKey: any(named: 'dateKey'),
        categoryId: 'beans',
        delta: 1,
      ),
    ).thenAnswer((_) async => log);

    final result = await repository.incrementCategoryProgress(
      categoryId: 'beans',
    );

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => _log()).id, log.id);
    verify(
      () => dataSource.updateCategoryProgress(
        dateKey: any(named: 'dateKey'),
        categoryId: 'beans',
        delta: 1,
      ),
    ).called(1);
  });
}

DailyLogModel _log() {
  return DailyLogModel(
    id: '2026-05-06',
    userId: 'user_1',
    logDate: DateTime.utc(2026, 5, 6),
    items: const <Never>[],
    totalCompleted: 0,
    totalTarget: 0,
    completionPercentage: 0,
    isFullyCompleted: false,
  );
}
