import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailUseCase extends UseCase<AuthUser, SignUpWithEmailParams> {
  SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(SignUpWithEmailParams params) {
    return _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class SignUpWithEmailParams extends Equatable {
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  @override
  List<Object?> get props => <Object?>[email, password, name];
}
