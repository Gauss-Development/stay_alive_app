import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.deleteAccount();
}
