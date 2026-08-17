import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';

class CheckSessionUseCase implements UseCase<AuthSession, NoParams> {
  CheckSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(NoParams params) {
    return _repository.checkSession();
  }
}
