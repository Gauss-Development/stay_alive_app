import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

class LoginWithOAuthUseCase
    implements UseCase<AuthSession, LoginWithOAuthParams> {
  LoginWithOAuthUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<AuthSession>> call(LoginWithOAuthParams params) {
    return _authRepository.loginWithOAuth(
      provider: params.provider,
    );
  }
}

class LoginWithOAuthParams extends Equatable {
  const LoginWithOAuthParams({
    required this.provider,
  });

  final OAuthSignInProvider provider;

  @override
  List<Object?> get props => <Object?>[provider];
}
