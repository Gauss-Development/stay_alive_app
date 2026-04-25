import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';

abstract class SubscriptionDataSource {
  Future<void> initialize(String apiKey);
  Future<List<SubscriptionPackage>> getOfferings();
  Future<SubscriptionInfo> getSubscriptionInfo();
  Future<SubscriptionInfo> purchasePackage(String packageIdentifier);
  Future<SubscriptionInfo> restorePurchases();
}

class RevenueCatSubscriptionDataSource implements SubscriptionDataSource {
  static const String _entitlementId = 'premium';

  @override
  Future<void> initialize(String apiKey) async {
    await Purchases.setLogLevel(LogLevel.info);
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  @override
  Future<List<SubscriptionPackage>> getOfferings() async {
    final Offerings offerings = await Purchases.getOfferings();
    final Offering? current = offerings.current;
    if (current == null) return <SubscriptionPackage>[];
    return current.availablePackages
        .map(_mapPackage)
        .toList();
  }

  @override
  Future<SubscriptionInfo> getSubscriptionInfo() async {
    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    return _mapCustomerInfo(customerInfo);
  }

  @override
  Future<SubscriptionInfo> purchasePackage(String packageIdentifier) async {
    final Offerings offerings = await Purchases.getOfferings();
    final Offering? current = offerings.current;
    if (current == null) {
      throw Exception('No offerings available');
    }
    final Package package = current.availablePackages.firstWhere(
      (Package p) => p.identifier == packageIdentifier,
      orElse: () => throw Exception('Package not found: $packageIdentifier'),
    );
    final CustomerInfo customerInfo = await Purchases.purchasePackage(package);
    return _mapCustomerInfo(customerInfo);
  }

  @override
  Future<SubscriptionInfo> restorePurchases() async {
    final CustomerInfo customerInfo = await Purchases.restorePurchases();
    return _mapCustomerInfo(customerInfo);
  }

  SubscriptionPackage _mapPackage(Package package) {
    return SubscriptionPackage(
      identifier: package.identifier,
      packageType: _mapPackageType(package.packageType),
      priceString: package.storeProduct.priceString,
      price: package.storeProduct.price,
      currencyCode: package.storeProduct.currencyCode,
      title: package.storeProduct.title,
    );
  }

  SubPackageType _mapPackageType(PackageType type) {
    switch (type) {
      case PackageType.weekly:
        return SubPackageType.weekly;
      case PackageType.monthly:
        return SubPackageType.monthly;
      case PackageType.annual:
        return SubPackageType.annual;
      default:
        return SubPackageType.unknown;
    }
  }

  SubscriptionInfo _mapCustomerInfo(CustomerInfo customerInfo) {
    final EntitlementInfo? entitlement =
        customerInfo.entitlements.active[_entitlementId];
    if (entitlement == null) {
      return SubscriptionInfo.inactive;
    }
    return SubscriptionInfo(
      isActive: entitlement.isActive,
      productIdentifier: entitlement.productIdentifier,
      expiresAt: entitlement.expirationDate != null
          ? DateTime.tryParse(entitlement.expirationDate!)
          : null,
      isTrial: entitlement.periodType == PeriodType.trial,
    );
  }
}
