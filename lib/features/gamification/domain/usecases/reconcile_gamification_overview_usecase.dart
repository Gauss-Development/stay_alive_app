import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_params.dart';

class ReconcileGamificationOverviewUseCase
    implements UseCase<GamificationOverview, ReconcileGamificationParams> {
  const ReconcileGamificationOverviewUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<GamificationOverview>> call(
    ReconcileGamificationParams params,
  ) {
    return _repository.reconcileOverview(
      isPremium: params.isPremium,
      personalizedDailyDraft: params.personalizedDailyDraft,
    );
  }
}
