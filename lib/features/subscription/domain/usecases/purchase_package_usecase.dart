import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';

class PurchasePackageParams {
  const PurchasePackageParams(this.packageIdentifier);

  final String packageIdentifier;
}

class PurchasePackageUseCase implements UseCase<SubscriptionInfo, PurchasePackageParams> {
  const PurchasePackageUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<SubscriptionInfo>> call(PurchasePackageParams params) =>
      _repository.purchasePackage(params.packageIdentifier);
}
