import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_overview_model.dart';
import 'package:stay_alive/features/gamification/data/repositories_impl/gamification_repository_impl.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class _MockGamificationRemoteDataSource extends Mock
    implements GamificationRemoteDataSource {}

void main() {
  late _MockGamificationRemoteDataSource dataSource;
  late GamificationRepositoryImpl repository;

  final GamificationOverviewModel overview = GamificationOverviewModel(
    profile: UserGameProfile(
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
    ),
    dailyChallenge: const GamificationChallenge(
      id: 'daily_2026-06-28',
      type: ChallengeType.logServings,
      title: 'Servings Sprint',
      description: 'Log 8 servings today.',
      target: 8,
      progress: 2,
      xpReward: 35,
      dateKey: '2026-06-28',
    ),
    categoryMastery: const <CategoryMastery>[],
    recentXpEvents: const <GamificationXpEvent>[],
  );

  setUp(() {
    dataSource = _MockGamificationRemoteDataSource();
    repository = GamificationRepositoryImpl(dataSource);
  });

  test('returns overview from remote reconcile', () async {
    when(() => dataSource.reconcileOverview()).thenAnswer((_) async => overview);

    final result = await repository.reconcileOverview();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected overview'),
      (GamificationOverview value) => expect(value, overview),
    );
  });

  test('maps remote exceptions to failures', () async {
    when(() => dataSource.reconcileOverview()).thenThrow(Exception('boom'));

    final result = await repository.reconcileOverview();

    expect(result.isLeft(), isTrue);
  });
}
