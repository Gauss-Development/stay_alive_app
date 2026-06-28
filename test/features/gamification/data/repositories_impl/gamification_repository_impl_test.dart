import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/data/models/user_game_profile_model.dart';
import 'package:stay_alive/features/gamification/data/repositories_impl/gamification_repository_impl.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class _MockGamificationRemoteDataSource extends Mock
    implements GamificationRemoteDataSource {}

void main() {
  late _MockGamificationRemoteDataSource dataSource;
  late GamificationRepositoryImpl repository;

  final UserGameProfileModel profile = UserGameProfileModel(
    userId: 'user_1',
    totalXp: 120,
    currentLevel: GameLevelTable.levels.first,
    currentStreak: 1,
    longestStreak: 2,
    activityStreak: 1,
    completedDates: <String>['2026-05-01'],
    earlyLogDates: <String>[],
    earnedBadges: <EarnedBadge>[],
    totalCategoriesCompleted: 1,
  );

  setUp(() {
    dataSource = _MockGamificationRemoteDataSource();
    repository = GamificationRepositoryImpl(dataSource);
  });

  test('returns profile from remote reconcile', () async {
    when(() => dataSource.reconcileProgress()).thenAnswer((_) async => profile);

    final result = await repository.reconcileProgress();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected profile'),
      (UserGameProfile value) => expect(value, profile),
    );
  });

  test('maps remote exceptions to failures', () async {
    when(() => dataSource.reconcileProgress()).thenThrow(Exception('boom'));

    final result = await repository.reconcileProgress();

    expect(result.isLeft(), isTrue);
    result.fold(
      (Failure failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected failure'),
    );
  });
}
