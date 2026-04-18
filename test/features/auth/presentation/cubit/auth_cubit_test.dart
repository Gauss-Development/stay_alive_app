import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_oauth_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/logout_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';

class _MockLoginWithEmailUseCase extends Mock
    implements LoginWithEmailUseCase {}

class _MockSignUpWithEmailUseCase extends Mock
    implements SignUpWithEmailUseCase {}

class _MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockLoginWithOAuthUseCase extends Mock implements LoginWithOAuthUseCase {}

class _MockCompleteOnboardingUseCase extends Mock
    implements CompleteOnboardingUseCase {}

class _MockAppLogger extends Mock implements AppLogger {}

class _FakeLoginWithEmailParams extends Fake implements LoginWithEmailParams {}

class _FakeSignUpWithEmailParams extends Fake implements SignUpWithEmailParams {}

class _FakeLoginWithOAuthParams extends Fake implements LoginWithOAuthParams {}

class _FakeNoParams extends Fake implements NoParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLoginWithEmailParams());
    registerFallbackValue(_FakeSignUpWithEmailParams());
    registerFallbackValue(_FakeLoginWithOAuthParams());
    registerFallbackValue(_FakeNoParams());
  });

  late _MockLoginWithEmailUseCase loginWithEmailUseCase;
  late _MockSignUpWithEmailUseCase signUpWithEmailUseCase;
  late _MockGetCurrentUserUseCase getCurrentUserUseCase;
  late _MockLogoutUseCase logoutUseCase;
  late _MockLoginWithOAuthUseCase loginWithOAuthUseCase;
  late _MockCompleteOnboardingUseCase completeOnboardingUseCase;
  late _MockAppLogger logger;

  late AuthUser user;
  late AuthSession session;

  setUp(() {
    loginWithEmailUseCase = _MockLoginWithEmailUseCase();
    signUpWithEmailUseCase = _MockSignUpWithEmailUseCase();
    getCurrentUserUseCase = _MockGetCurrentUserUseCase();
    logoutUseCase = _MockLogoutUseCase();
    loginWithOAuthUseCase = _MockLoginWithOAuthUseCase();
    completeOnboardingUseCase = _MockCompleteOnboardingUseCase();
    logger = _MockAppLogger();

    when(() => logger.debug(any(), data: any(named: 'data'))).thenReturn(null);

    user = const AuthUser(
      id: 'user_1',
      email: 'user@example.com',
      displayName: 'User',
      emailVerified: true,
      preferences: <String, dynamic>{'onboardingCompleted': true},
    );

    session = AuthSession(
      id: 'session_1',
      userId: 'user_1',
      provider: 'email',
      expire: DateTime.parse('2030-01-01T00:00:00Z'),
    );
  });

  AuthCubit buildCubit() {
    return AuthCubit(
      loginWithEmailUseCase: loginWithEmailUseCase,
      signUpWithEmailUseCase: signUpWithEmailUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      logoutUseCase: logoutUseCase,
      loginWithOAuthUseCase: loginWithOAuthUseCase,
      completeOnboardingUseCase: completeOnboardingUseCase,
      logger: logger,
    );
  }

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when sign-in succeeds',
    build: () {
      when(() => loginWithEmailUseCase(any())).thenAnswer(
        (_) async => Right<Failure, AuthSession>(session),
      );
      when(() => getCurrentUserUseCase(any())).thenAnswer(
        (_) async => Right<Failure, AuthUser>(user),
      );
      return buildCubit();
    },
    act: (AuthCubit cubit) => cubit.signInWithEmail(
      email: 'user@example.com',
      password: 'password123',
    ),
    expect: () => <AuthState>[
      const AuthLoading(),
      AuthAuthenticated(user),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthError] when sign-in fails',
    build: () {
      when(() => loginWithEmailUseCase(any())).thenAnswer(
        (_) async => const Left<Failure, AuthSession>(
          AuthFailure('Invalid credentials'),
        ),
      );
      return buildCubit();
    },
    act: (AuthCubit cubit) => cubit.signInWithEmail(
      email: 'user@example.com',
      password: 'bad-password',
    ),
    expect: () => <AuthState>[
      const AuthLoading(),
      const AuthError('Invalid credentials'),
    ],
  );
}
