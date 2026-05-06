import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';

class RestorePurchasesUseCase implements UseCase<SubscriptionInfo, NoParams> {
  const RestorePurchasesUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<SubscriptionInfo>> call(NoParams params) {
    return _repository.restorePurchases();
  }
}
