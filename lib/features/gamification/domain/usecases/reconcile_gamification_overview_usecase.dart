import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class ReconcileGamificationOverviewUseCase
    implements UseCase<GamificationOverview, NoParams> {
  const ReconcileGamificationOverviewUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<GamificationOverview>> call(NoParams params) {
    return _repository.reconcileOverview();
  }
}
