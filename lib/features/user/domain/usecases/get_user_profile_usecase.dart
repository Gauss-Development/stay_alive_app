import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';
import 'package:stay_alive/features/user/domain/repositories/user_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  const GetUserProfileUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<UserProfile>> call(NoParams params) {
    return _repository.getProfile();
  }
}
