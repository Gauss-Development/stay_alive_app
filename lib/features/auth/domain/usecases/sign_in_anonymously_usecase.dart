import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

/// Dev-only: creates a real Appwrite anonymous session so the app has a valid
/// `account` scope without real credentials. Wired only into the dev "Mock
/// login" button; not used by the production auth flow.
class SignInAnonymouslyUseCase implements UseCase<AuthUser, NoParams> {
  SignInAnonymouslyUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(NoParams params) {
    return _repository.signInAnonymously();
  }
}
