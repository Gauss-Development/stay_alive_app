import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart'
    show OAuthSignInProvider;

class LoginWithOAuthUseCase implements UseCase<void, LoginWithOAuthParams> {
  LoginWithOAuthUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(LoginWithOAuthParams params) {
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
