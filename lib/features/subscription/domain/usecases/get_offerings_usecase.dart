import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';

class GetOfferingsUseCase implements UseCase<List<SubscriptionPackage>, NoParams> {
  const GetOfferingsUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<List<SubscriptionPackage>>> call(NoParams params) =>
      _repository.getOfferings();
}
