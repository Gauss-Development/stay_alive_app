import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_progress_model.dart';
import 'package:stay_alive/features/gamification/data/repositories_impl/gamification_repository_impl.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';

class _MockGamificationRemoteDataSource extends Mock
    implements GamificationRemoteDataSource {}

void main() {
  late _MockGamificationRemoteDataSource dataSource;
  late GamificationRepositoryImpl repository;

  const GamificationProgressModel progress = GamificationProgressModel(
    userId: 'user_1',
    xp: 125,
    level: 2,
    currentLevelXp: 100,
    nextLevelXp: 200,
    currentStreak: 1,
    bestStreak: 2,
    completedDays: 3,
    lastCompletedDate: '2026-05-06',
    badges: <String>['first_log'],
  );

  setUp(() {
    dataSource = _MockGamificationRemoteDataSource();
    repository = GamificationRepositoryImpl(dataSource);
  });

  test('returns progress when datasource succeeds', () async {
    when(() => dataSource.fetchProgress()).thenAnswer((_) async => progress);

    final result = await repository.getProgress();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected progress'),
      (GamificationProgress value) => expect(value, progress),
    );
  });

  test('maps datasource errors to failures', () async {
    when(() => dataSource.fetchProgress()).thenThrow(Exception('boom'));

    final result = await repository.getProgress();

    expect(result.isLeft(), isTrue);
    result.fold(
      (Failure failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected failure'),
    );
  });
}
