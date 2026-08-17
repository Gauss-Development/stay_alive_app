import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_params.dart';

class ReconcileGamificationTodayUseCase
    implements UseCase<GamificationOverview, ReconcileGamificationTodayParams> {
  const ReconcileGamificationTodayUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<GamificationOverview>> call(
    ReconcileGamificationTodayParams params,
  ) {
    return _repository.reconcileTodayOverview(
      todayLog: params.todayLog,
      isPremium: params.isPremium,
    );
  }
}
