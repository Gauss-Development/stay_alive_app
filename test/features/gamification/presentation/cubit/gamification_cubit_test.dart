import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_progress_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class _MockReconcileGamificationProgressUseCase extends Mock
    implements ReconcileGamificationProgressUseCase {}

void main() {
  late _MockReconcileGamificationProgressUseCase useCase;

  final UserGameProfile profile = UserGameProfile(
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

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    useCase = _MockReconcileGamificationProgressUseCase();
  });

  GamificationCubit buildCubit() {
    return GamificationCubit(
      reconcileGamificationProgressUseCase: useCase,
    );
  }

  blocTest<GamificationCubit, GamificationState>(
    'emits loaded state when load succeeds',
    build: buildCubit,
    setUp: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => Right<Failure, UserGameProfile>(profile),
      );
    },
    act: (GamificationCubit cubit) => cubit.load(),
    expect: () => <GamificationState>[
      const GamificationLoading(),
      GamificationLoaded(profile: profile),
    ],
  );

  blocTest<GamificationCubit, GamificationState>(
    'emits error when load fails',
    build: buildCubit,
    setUp: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Left<Failure, UserGameProfile>(
          UnknownFailure('Could not load progress'),
        ),
      );
    },
    act: (GamificationCubit cubit) => cubit.load(),
    expect: () => <GamificationState>[
      const GamificationLoading(),
      const GamificationError('Could not load progress'),
    ],
  );
}
