import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmailUseCase implements UseCase<AuthSession, LoginWithEmailParams> {
  LoginWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(LoginWithEmailParams params) {
    return _repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginWithEmailParams extends Equatable {
  const LoginWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}
