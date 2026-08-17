import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
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

GamificationOverviewModel _overviewFixture() {
  return GamificationOverviewModel(
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
    weeklyChallenge: const GamificationChallenge(
      id: 'weekly_2026-06-23',
      type: ChallengeType.perfectDaysInWeek,
      title: 'Weekly Perfectionist',
      description: 'Hit 3 perfect days this week.',
      target: 3,
      progress: 1,
      xpReward: 120,
      dateKey: '2026-06-23',
      period: ChallengePeriod.weekly,
    ),
    categoryMastery: const <CategoryMastery>[],
    recentXpEvents: const <GamificationXpEvent>[],
  );
}

void main() {
  late _MockGamificationRemoteDataSource dataSource;
  late GamificationRepositoryImpl repository;

  setUp(() {
    dataSource = _MockGamificationRemoteDataSource();
    repository = GamificationRepositoryImpl(dataSource);
  });

  test('returns overview from remote reconcile', () async {
    final GamificationOverviewModel overview = _overviewFixture();
    when(
      () => dataSource.reconcileOverview(isPremium: false),
    ).thenAnswer((_) async => overview);

    final result = await repository.reconcileOverview(isPremium: false);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected overview'),
      (GamificationOverview value) => expect(value, overview),
    );
  });

  test('returns today overview from remote incremental reconcile', () async {
    final GamificationOverviewModel overview = _overviewFixture();
    final DailyLog todayLog = DailyLog(
      id: '2026-06-28',
      userId: 'user_1',
      logDate: DateTime.parse('2026-06-28T12:00:00'),
      items: const <DailyLogItem>[],
      totalCompleted: 1,
      totalTarget: 3,
      completionPercentage: 33,
      isFullyCompleted: false,
    );
    when(
      () => dataSource.reconcileTodayOverview(
        todayLog: todayLog,
        isPremium: true,
      ),
    ).thenAnswer((_) async => overview);

    final result = await repository.reconcileTodayOverview(
      todayLog: todayLog,
      isPremium: true,
    );

    expect(result.isRight(), isTrue);
  });

  test('maps remote exceptions to failures', () async {
    when(
      () => dataSource.reconcileOverview(isPremium: false),
    ).thenThrow(Exception('boom'));

    final result = await repository.reconcileOverview(isPremium: false);

    expect(result.isLeft(), isTrue);
  });
}
