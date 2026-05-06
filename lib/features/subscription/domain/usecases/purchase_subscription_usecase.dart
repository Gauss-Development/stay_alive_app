import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';

class PurchaseSubscriptionUseCase
    implements UseCase<SubscriptionInfo, PurchaseSubscriptionParams> {
  const PurchaseSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<SubscriptionInfo>> call(PurchaseSubscriptionParams params) {
    return _repository.purchasePackage(params.packageId);
  }
}

class PurchaseSubscriptionParams extends Equatable {
  const PurchaseSubscriptionParams({required this.packageId});

  final String packageId;

  @override
  List<Object?> get props => <Object?>[packageId];
}
