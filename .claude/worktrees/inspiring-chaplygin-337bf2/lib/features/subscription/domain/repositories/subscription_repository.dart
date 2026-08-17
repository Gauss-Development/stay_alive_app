import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';

abstract class SubscriptionRepository {
  Future<Result<SubscriptionInfo>> getSubscriptionStatus();

  Future<Result<SubscriptionOffering>> getOffering();

  Future<Result<SubscriptionInfo>> purchasePackage(String packageId);

  Future<Result<SubscriptionInfo>> restorePurchases();
}
