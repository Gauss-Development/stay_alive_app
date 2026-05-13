import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';
import 'package:stay_alive/features/gamification/domain/usecases/get_gamification_progress_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class _MockGetGamificationProgressUseCase extends Mock
    implements GetGamificationProgressUseCase {}

class _FakeNoParams extends Fake implements NoParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeNoParams());
  });

  late _MockGetGamificationProgressUseCase useCase;

  const GamificationProgress progress = GamificationProgress(
    userId: 'user_1',
    xp: 145,
    level: 2,
    currentLevelXp: 100,
    nextLevelXp: 200,
    currentStreak: 2,
    bestStreak: 3,
    completedDays: 4,
    lastCompletedDate: '2026-05-06',
    badges: <String>['first_log', 'perfect_day'],
  );

  setUp(() {
    useCase = _MockGetGamificationProgressUseCase();
  });

  GamificationCubit buildCubit() {
    return GamificationCubit(getGamificationProgressUseCase: useCase);
  }

  blocTest<GamificationCubit, GamificationState>(
    'emits loading then loaded when progress loads',
    build: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Right<Failure, GamificationProgress>(progress),
      );
      return buildCubit();
    },
    act: (GamificationCubit cubit) => cubit.load(),
    expect: () => <GamificationState>[
      const GamificationLoading(),
      const GamificationLoaded(progress),
    ],
  );

  blocTest<GamificationCubit, GamificationState>(
    'emits loading then error when progress fails',
    build: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Left<Failure, GamificationProgress>(
          DatabaseFailure('Could not load rewards'),
        ),
      );
      return buildCubit();
    },
    act: (GamificationCubit cubit) => cubit.load(),
    expect: () => <GamificationState>[
      const GamificationLoading(),
      const GamificationError('Could not load rewards'),
    ],
  );
}
