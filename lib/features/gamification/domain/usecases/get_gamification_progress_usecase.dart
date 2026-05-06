import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class GetGamificationProgressUseCase
    implements UseCase<GamificationProgress, NoParams> {
  const GetGamificationProgressUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<GamificationProgress>> call(NoParams params) {
    return _repository.getProgress();
  }
}
