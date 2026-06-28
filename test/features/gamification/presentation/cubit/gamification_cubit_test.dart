import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_overview_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:bloc_test/bloc_test.dart';

class _MockReconcileGamificationOverviewUseCase extends Mock
    implements ReconcileGamificationOverviewUseCase {}

void main() {
  late _MockReconcileGamificationOverviewUseCase useCase;

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
    categoryMastery: const <CategoryMastery>[],
    recentXpEvents: const <GamificationXpEvent>[],
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    useCase = _MockReconcileGamificationOverviewUseCase();
  });

  GamificationCubit buildCubit() {
    return GamificationCubit(
      reconcileGamificationOverviewUseCase: useCase,
    );
  }

  blocTest<GamificationCubit, GamificationState>(
    'emits loaded overview when load succeeds',
    build: buildCubit,
    setUp: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => Right<Failure, GamificationOverview>(overview),
      );
    },
    act: (GamificationCubit cubit) => cubit.load(),
    expect: () => <GamificationState>[
      const GamificationLoading(),
      GamificationLoaded(overview: overview),
    ],
  );
}
