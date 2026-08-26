import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/subscription/data/datasources/revenue_cat_subscription_data_source.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_info.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_offering.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Dev-only store: shows a fake offering and "purchases" premium instantly,
/// so the full paywall → purchase → unlocked flow is testable on simulators
/// where RevenueCat has no real store.
///
/// The purchase is persisted in the Supabase user's `user_metadata`
/// (`mock_premium`), so it survives app restarts and resets naturally when
/// you log in as a fresh guest. Wired by DI only when the dev flavor still
/// runs on the committed `test_` RevenueCat keys; drop real sandbox keys into
/// env and the real gateway takes over automatically.
class MockSubscriptionRemoteDataSource implements SubscriptionRemoteDataSource {
  MockSubscriptionRemoteDataSource({
    required supabase.GoTrueClient auth,
    required AppLogger logger,
  })  : _auth = auth,
        _logger = logger;

  final supabase.GoTrueClient _auth;
  final AppLogger _logger;

  static const String _metadataKey = 'mock_premium';

  static const SubscriptionOffering _offering = SubscriptionOffering(
    packages: <SubscriptionPackage>[
      SubscriptionPackage(
        id: r'$rc_monthly',
        plan: SubscriptionPlan.monthly,
        title: 'Месяц',
        description: 'Все Premium-функции',
        priceLabel: '299 ₽',
        productIdentifier: 'com.gaussdev.stayalive.premium.monthly',
      ),
      SubscriptionPackage(
        id: r'$rc_annual',
        plan: SubscriptionPlan.annual,
        title: 'Год',
        description: 'Все Premium-функции, выгоднее на 45%',
        priceLabel: '1 990 ₽',
        productIdentifier: 'com.gaussdev.stayalive.premium.annual',
      ),
    ],
  );

  @override
  Future<void> initialize() async {
    _logger.info('Mock store active (dev): purchases are simulated');
  }

  @override
  Future<SubscriptionInfo> getSubscriptionStatus() async => _currentInfo();

  @override
  Future<SubscriptionOffering> getOffering() async => _offering;

  @override
  Future<SubscriptionInfo> purchasePackage(String packageId) async {
    // A beat of latency so loading states are visible, like a real store.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final SubscriptionPackage? package = _offering.packageForId(packageId);
    final SubscriptionPlan plan = package?.plan ?? SubscriptionPlan.monthly;
    await _persist(plan);
    _logger.info(
      'Mock purchase completed',
      data: <String, Object?>{'package': packageId, 'plan': plan.name},
    );
    return _currentInfo();
  }

  @override
  Future<SubscriptionInfo> restorePurchases() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!_currentInfo().isPremiumActive) {
      await _persist(SubscriptionPlan.monthly);
    }
    _logger.info('Mock restore completed');
    return _currentInfo();
  }

  SubscriptionInfo _currentInfo() {
    final Object? stored = _auth.currentUser?.userMetadata?[_metadataKey];
    final SubscriptionPlan? plan = switch (stored) {
      'monthly' => SubscriptionPlan.monthly,
      'annual' => SubscriptionPlan.annual,
      _ => null,
    };
    if (plan == null) {
      return const SubscriptionInfo.free();
    }
    return SubscriptionInfo(
      plan: plan,
      status: SubscriptionStatus.active,
      productIdentifier: plan == SubscriptionPlan.annual
          ? 'com.gaussdev.stayalive.premium.annual'
          : 'com.gaussdev.stayalive.premium.monthly',
      expiresAt: DateTime.now().add(
        plan == SubscriptionPlan.annual
            ? const Duration(days: 365)
            : const Duration(days: 30),
      ),
    );
  }

  Future<void> _persist(SubscriptionPlan plan) async {
    try {
      await _auth.updateUser(
        supabase.UserAttributes(
          data: <String, dynamic>{_metadataKey: plan.name},
        ),
      );
    } on supabase.AuthException catch (exception) {
      _logger.warning(
        'Mock purchase not persisted (no session?)',
        data: <String, Object?>{'reason': exception.message},
      );
    }
  }
}
