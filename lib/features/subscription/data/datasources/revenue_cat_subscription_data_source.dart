import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class RevenueCatGateway {
  Future<void> configure({required String apiKey, String? appUserId});

  Future<void> logIn(String appUserId);

  Future<CustomerInfo> getCustomerInfo();

  Future<Offerings> getOfferings();

  Future<CustomerInfo> purchasePackage(Package package);

  Future<void> syncPurchases();

  Future<CustomerInfo> restorePurchases();
}

class PurchasesRevenueCatGateway implements RevenueCatGateway {
  const PurchasesRevenueCatGateway();

  @override
  Future<void> configure({required String apiKey, String? appUserId}) {
    final PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
    if (appUserId != null && appUserId.isNotEmpty) {
      configuration.appUserID = appUserId;
    }
    return Purchases.configure(configuration);
  }

  @override
  Future<void> logIn(String appUserId) async {
    await Purchases.logIn(appUserId);
  }

  @override
  Future<CustomerInfo> getCustomerInfo() {
    return Purchases.getCustomerInfo();
  }

  @override
  Future<Offerings> getOfferings() {
    return Purchases.getOfferings();
  }

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    final PurchaseResult result = await Purchases.purchase(
      PurchaseParams.package(package),
    );
    return result.customerInfo;
  }

  @override
  Future<void> syncPurchases() {
    return Purchases.syncPurchases();
  }

  @override
  Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }
}

abstract class SubscriptionRemoteDataSource {
  Future<void> initialize();

  Future<SubscriptionInfo> getSubscriptionStatus();

  Future<SubscriptionOffering> getOffering();

  Future<SubscriptionInfo> purchasePackage(String packageId);

  Future<SubscriptionInfo> restorePurchases();
}

class RevenueCatSubscriptionRemoteDataSource
    implements SubscriptionRemoteDataSource {
  RevenueCatSubscriptionRemoteDataSource({
    required RevenueCatGateway revenueCatGateway,
    required supabase.GoTrueClient auth,
    required EnvConfig envConfig,
    required AppLogger logger,
  }) : _revenueCatGateway = revenueCatGateway,
       _auth = auth,
       _envConfig = envConfig,
       _logger = logger;

  final RevenueCatGateway _revenueCatGateway;
  final supabase.GoTrueClient _auth;
  final EnvConfig _envConfig;
  final AppLogger _logger;
  final Map<String, Package> _packagesById = <String, Package>{};

  bool _isConfigured = false;

  @override
  Future<void> initialize() async {
    if (_isConfigured) {
      return;
    }
    final String apiKey = _apiKeyForPlatform();
    if (apiKey.isEmpty) {
      _logger.warning(
        'RevenueCat API key is not configured; subscriptions are inactive.',
      );
      return;
    }
    final String? appUserId = await _currentUserIdOrNull();
    await _revenueCatGateway.configure(apiKey: apiKey, appUserId: appUserId);
    _isConfigured = true;
  }

  @override
  Future<SubscriptionInfo> getSubscriptionStatus() async {
    await initialize();
    if (!_isConfigured) {
      return const SubscriptionInfo.free();
    }
    await _logInCurrentUserIfPossible();
    final CustomerInfo customerInfo = await _revenueCatGateway
        .getCustomerInfo();
    return _mapCustomerInfo(customerInfo);
  }

  @override
  Future<SubscriptionOffering> getOffering() async {
    await initialize();
    if (!_isConfigured) {
      return SubscriptionOffering(
        packages: _fallbackPackages(),
        isConfigured: false,
      );
    }
    await _logInCurrentUserIfPossible();
    final Offerings offerings = await _revenueCatGateway.getOfferings();
    final Offering? selectedOffering =
        offerings.all[_envConfig.revenueCatOfferingId] ?? offerings.current;
    final List<Package> revenueCatPackages =
        selectedOffering?.availablePackages ?? <Package>[];
    _packagesById
      ..clear()
      ..addEntries(
        revenueCatPackages.map(
          (Package package) =>
              MapEntry<String, Package>(_packageIdFor(package), package),
        ),
      );

    final List<SubscriptionPackage> packages =
        revenueCatPackages
            .map(_mapPackage)
            .where((SubscriptionPackage package) => package.plan.isPaid)
            .toList(growable: false)
          ..sort(
            (SubscriptionPackage a, SubscriptionPackage b) =>
                a.plan.sortOrder.compareTo(b.plan.sortOrder),
          );

    return SubscriptionOffering(
      packages: packages.isEmpty ? _fallbackPackages() : packages,
      isConfigured: packages.isNotEmpty,
    );
  }

  @override
  Future<SubscriptionInfo> purchasePackage(String packageId) async {
    await initialize();
    if (!_isConfigured) {
      throw StateError('RevenueCat is not configured.');
    }
    await _logInCurrentUserIfPossible();
    if (!_packagesById.containsKey(packageId)) {
      await getOffering();
    }
    final Package? package = _packagesById[packageId];
    if (package == null) {
      throw ArgumentError('Unknown subscription package: $packageId');
    }
    final CustomerInfo purchaseInfo = await _revenueCatGateway.purchasePackage(
      package,
    );
    var info = _mapCustomerInfo(purchaseInfo);
    if (!info.isPremiumActive) {
      await _revenueCatGateway.syncPurchases();
      final CustomerInfo refreshed = await _revenueCatGateway.getCustomerInfo();
      info = _mapCustomerInfo(refreshed);
    }
    return info;
  }

  @override
  Future<SubscriptionInfo> restorePurchases() async {
    await initialize();
    if (!_isConfigured) {
      return const SubscriptionInfo.free();
    }
    await _logInCurrentUserIfPossible();
    final CustomerInfo customerInfo = await _revenueCatGateway
        .restorePurchases();
    return _mapCustomerInfo(customerInfo);
  }

  SubscriptionInfo _mapCustomerInfo(CustomerInfo customerInfo) {
    final EntitlementInfo? entitlement = _resolveActiveEntitlement(customerInfo);
    if (entitlement != null) {
      final String productIdentifier = entitlement.productIdentifier;
      final SubscriptionPlan plan = SubscriptionPlan.fromRevenueCatIdentifier(
        productIdentifier,
      );
      return SubscriptionInfo(
        plan: plan,
        status: SubscriptionStatus.active,
        productIdentifier: productIdentifier,
        expiresAt: _parseExpirationDate(entitlement.expirationDate),
        managementUrl: customerInfo.managementURL,
      );
    }

    if (customerInfo.activeSubscriptions.isNotEmpty) {
      final String productIdentifier = customerInfo.activeSubscriptions.first;
      _logger.warning(
        'No active entitlement "${_envConfig.revenueCatEntitlementId}"; '
        'inferring premium from active subscription $productIdentifier.',
      );
      return SubscriptionInfo(
        plan: SubscriptionPlan.fromRevenueCatIdentifier(productIdentifier),
        status: SubscriptionStatus.active,
        productIdentifier: productIdentifier,
        expiresAt: _parseExpirationDate(
          customerInfo.allExpirationDates[productIdentifier],
        ),
        managementUrl: customerInfo.managementURL,
      );
    }

    return const SubscriptionInfo.free();
  }

  EntitlementInfo? _resolveActiveEntitlement(CustomerInfo customerInfo) {
    final String configuredId = _envConfig.revenueCatEntitlementId;
    final EntitlementInfo? configuredEntitlement =
        customerInfo.entitlements.active[configuredId];
    if (configuredEntitlement != null) {
      return configuredEntitlement;
    }

    final Map<String, EntitlementInfo> activeEntitlements =
        customerInfo.entitlements.active;
    if (activeEntitlements.isEmpty) {
      return null;
    }

    final EntitlementInfo fallback = activeEntitlements.values.first;
    _logger.warning(
      'Entitlement "$configuredId" is not active; using '
      '"${fallback.identifier}" instead.',
    );
    return fallback;
  }

  DateTime? _parseExpirationDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDate);
  }

  SubscriptionPackage _mapPackage(Package package) {
    final SubscriptionPlan plan = SubscriptionPlan.fromRevenueCatIdentifier(
      '${package.identifier} ${package.packageType} '
      '${package.storeProduct.identifier}',
    );
    return SubscriptionPackage(
      id: _packageIdFor(package),
      plan: plan,
      title: _titleFor(plan),
      description: _descriptionFor(plan),
      priceLabel: package.storeProduct.priceString,
      productIdentifier: package.storeProduct.identifier,
    );
  }

  List<SubscriptionPackage> _fallbackPackages() {
    return SubscriptionPlan.values
        .where((SubscriptionPlan plan) => plan.isPaid)
        .map(
          (SubscriptionPlan plan) => SubscriptionPackage(
            id: plan.revenueCatPackageId,
            plan: plan,
            title: _titleFor(plan),
            description: _descriptionFor(plan),
            priceLabel: plan.defaultPriceLabel,
            productIdentifier: plan.revenueCatPackageId,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _logInCurrentUserIfPossible() async {
    final String? userId = await _currentUserIdOrNull();
    if (userId != null) {
      await _revenueCatGateway.logIn(userId);
    }
  }

  Future<String?> _currentUserIdOrNull() async {
    // The Supabase auth user id doubles as the RevenueCat appUserID.
    return _auth.currentUser?.id;
  }

  String _apiKeyForPlatform() {
    if (Platform.isIOS || Platform.isMacOS) {
      return _envConfig.revenueCatIosApiKey;
    }
    if (Platform.isAndroid) {
      return _envConfig.revenueCatAndroidApiKey;
    }
    return _envConfig.revenueCatAndroidApiKey.isNotEmpty
        ? _envConfig.revenueCatAndroidApiKey
        : _envConfig.revenueCatIosApiKey;
  }

  String _packageIdFor(Package package) {
    return package.identifier.isEmpty
        ? package.storeProduct.identifier
        : package.identifier;
  }

  String _titleFor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.monthly:
        return 'Monthly';
      case SubscriptionPlan.annual:
        return 'Annual';
    }
  }

  String _descriptionFor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Track daily fruit and vegetable intake for free.';
      case SubscriptionPlan.monthly:
        return 'Unlock full statistics and habit trends every month.';
      case SubscriptionPlan.annual:
        return 'Best value for a full year of healthy habit coaching.';
    }
  }
}
