import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_state.dart';

class _MockCheckSessionUseCase extends Mock implements CheckSessionUseCase {}

class _MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class _MockAppLogger extends Mock implements AppLogger {}

class _FakeNoParams extends Fake implements NoParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeNoParams());
  });

  late _MockCheckSessionUseCase checkSessionUseCase;
  late _MockGetCurrentUserUseCase getCurrentUserUseCase;
  late _MockAppLogger logger;

  setUp(() {
    checkSessionUseCase = _MockCheckSessionUseCase();
    getCurrentUserUseCase = _MockGetCurrentUserUseCase();
    logger = _MockAppLogger();

    when(() => logger.warning(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => logger.info(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => logger.error(any(), data: any(named: 'data'))).thenReturn(null);
  });

  AppStartupCubit buildCubit() {
    return AppStartupCubit(
      checkSessionUseCase: checkSessionUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      logger: logger,
    );
  }

  blocTest<AppStartupCubit, AppStartupState>(
    'emits loading then unauthenticated when no active session',
    build: () {
      when(() => checkSessionUseCase(any())).thenAnswer(
        (_) async => const Left<Failure, AuthSession>(
          AuthFailure('No active session found.'),
        ),
      );
      return buildCubit();
    },
    act: (AppStartupCubit cubit) => cubit.initialize(),
    expect: () => const <AppStartupState>[
      AppStartupState.loading(),
      AppStartupState.unauthenticated(),
    ],
  );

  blocTest<AppStartupCubit, AppStartupState>(
    'emits loading then authenticated when session and user exist',
    build: () {
      final AuthSession session = AuthSession(
        id: 'session_1',
        userId: 'user_1',
        provider: 'email',
        expire: DateTime.parse('2030-01-01T00:00:00Z'),
      );
      const AuthUser user = AuthUser(
        id: 'user_1',
        email: 'user@example.com',
        displayName: 'User',
        emailVerified: true,
        preferences: <String, dynamic>{'onboardingCompleted': true},
      );

      when(() => checkSessionUseCase(any())).thenAnswer(
        (_) async => Right<Failure, AuthSession>(session),
      );
      when(() => getCurrentUserUseCase(any())).thenAnswer(
        (_) async => const Right<Failure, AuthUser>(user),
      );
      return buildCubit();
    },
    act: (AppStartupCubit cubit) => cubit.initialize(),
    expect: () => const <AppStartupState>[
      AppStartupState.loading(),
      AppStartupState.authenticated(
        AuthUser(
          id: 'user_1',
          email: 'user@example.com',
          displayName: 'User',
          emailVerified: true,
          preferences: <String, dynamic>{'onboardingCompleted': true},
        ),
      ),
    ],
  );

  blocTest<AppStartupCubit, AppStartupState>(
    'emits loading then onboardingRequired when user needs onboarding',
    build: () {
      final AuthSession session = AuthSession(
        id: 'session_2',
        userId: 'user_2',
        provider: 'email',
        expire: DateTime.parse('2030-01-01T00:00:00Z'),
      );
      const AuthUser user = AuthUser(
        id: 'user_2',
        email: 'new@example.com',
        displayName: 'New User',
        emailVerified: true,
        preferences: <String, dynamic>{'onboardingCompleted': false},
      );

      when(() => checkSessionUseCase(any())).thenAnswer(
        (_) async => Right<Failure, AuthSession>(session),
      );
      when(() => getCurrentUserUseCase(any())).thenAnswer(
        (_) async => const Right<Failure, AuthUser>(user),
      );
      return buildCubit();
    },
    act: (AppStartupCubit cubit) => cubit.initialize(),
    expect: () => const <AppStartupState>[
      AppStartupState.loading(),
      AppStartupState.onboardingRequired(
        AuthUser(
          id: 'user_2',
          email: 'new@example.com',
          displayName: 'New User',
          emailVerified: true,
          preferences: <String, dynamic>{'onboardingCompleted': false},
        ),
      ),
    ],
  );
}
