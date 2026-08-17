import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_overview_usecase.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_params.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_today_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:bloc_test/bloc_test.dart';

class _MockReconcileGamificationOverviewUseCase extends Mock
    implements ReconcileGamificationOverviewUseCase {}

class _MockReconcileGamificationTodayUseCase extends Mock
    implements ReconcileGamificationTodayUseCase {}

void main() {
  late _MockReconcileGamificationOverviewUseCase overviewUseCase;
  late _MockReconcileGamificationTodayUseCase todayUseCase;

  final GamificationOverview overview = GamificationOverview(
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

  setUpAll(() {
    registerFallbackValue(const ReconcileGamificationParams(isPremium: false));
    registerFallbackValue(
      ReconcileGamificationTodayParams(
        todayLog: DailyLog(
          id: '2026-06-28',
          userId: 'user_1',
          logDate: DateTime.parse('2026-06-28T12:00:00'),
          items: const <DailyLogItem>[],
          totalCompleted: 0,
          totalTarget: 0,
          completionPercentage: 0,
          isFullyCompleted: false,
        ),
        isPremium: false,
      ),
    );
  });

  setUp(() {
    overviewUseCase = _MockReconcileGamificationOverviewUseCase();
    todayUseCase = _MockReconcileGamificationTodayUseCase();
  });

  GamificationCubit buildCubit() {
    return GamificationCubit(
      reconcileGamificationOverviewUseCase: overviewUseCase,
      reconcileGamificationTodayUseCase: todayUseCase,
    );
  }

  blocTest<GamificationCubit, GamificationState>(
    'emits loaded overview when load succeeds',
    build: buildCubit,
    setUp: () {
      when(() => overviewUseCase(any())).thenAnswer(
        (_) async => Right<Failure, GamificationOverview>(overview),
      );
    },
    act: (GamificationCubit cubit) => cubit.load(isPremium: false),
    expect: () => <GamificationState>[
      const GamificationLoading(),
      GamificationLoaded(overview: overview),
    ],
  );
}
