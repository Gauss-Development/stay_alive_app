import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';

class GetSubscriptionOfferingUseCase
    implements UseCase<SubscriptionOffering, NoParams> {
  const GetSubscriptionOfferingUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<SubscriptionOffering>> call(NoParams params) {
    return _repository.getOffering();
  }
}
