import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_oauth_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/logout_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required LoginWithOAuthUseCase loginWithOAuthUseCase,
    required CompleteOnboardingUseCase completeOnboardingUseCase,
    required AppLogger logger,
  })  : _loginWithEmailUseCase = loginWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        _loginWithOAuthUseCase = loginWithOAuthUseCase,
        _completeOnboardingUseCase = completeOnboardingUseCase,
        _logger = logger,
        super(const AuthInitial());

  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final LoginWithOAuthUseCase _loginWithOAuthUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final AppLogger _logger;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final sessionResult = await _loginWithEmailUseCase(
      LoginWithEmailParams(email: email, password: password),
    );

    await sessionResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        await _loadCurrentUserAndEmit();
      },
    );
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _signUpWithEmailUseCase(
      SignUpWithEmailParams(
        email: email,
        password: password,
        name: name,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithOAuth({
    required OAuthSignInProvider provider,
  }) async {
    emit(const AuthLoading());
    final result = await _loginWithOAuthUseCase(
      LoginWithOAuthParams(provider: provider),
    );

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async => _loadCurrentUserAndEmit(),
    );
  }

  Future<void> completeOnboarding() async {
    emit(const AuthLoading());
    final result = await _completeOnboardingUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> loadCurrentUser() async {
    emit(const AuthLoading());
    await _loadCurrentUserAndEmit();
  }

  void restoreAuthenticatedUser(AuthUser user) {
    emit(AuthAuthenticated(user));
  }

  Future<void> logout() async {
    final result = await _logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _loadCurrentUserAndEmit() async {
    final userResult = await _getCurrentUserUseCase(const NoParams());
    userResult.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    _logger.debug(
      'AuthCubit state transition',
      data: <String, Object?>{
        'current': change.currentState.runtimeType.toString(),
        'next': change.nextState.runtimeType.toString(),
      },
    );
  }
}
