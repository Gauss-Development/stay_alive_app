import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class GetGameProfileUseCase implements UseCase<UserGameProfile, NoParams> {
  const GetGameProfileUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<UserGameProfile>> call(NoParams params) =>
      _repository.getProfile();
}
