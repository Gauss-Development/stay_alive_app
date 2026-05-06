import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_plan.dart';

enum SubscriptionStatus {
  free,
  active,
  expired,
}

class SubscriptionInfo extends Equatable {
  const SubscriptionInfo({
    required this.plan,
    required this.status,
    this.productIdentifier,
    this.expiresAt,
    this.managementUrl,
  });

  const SubscriptionInfo.free()
      : plan = SubscriptionPlan.free,
        status = SubscriptionStatus.free,
        productIdentifier = null,
        expiresAt = null,
        managementUrl = null;

  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final String? productIdentifier;
  final DateTime? expiresAt;
  final String? managementUrl;

  bool get isPremiumActive => status == SubscriptionStatus.active;

  @override
  List<Object?> get props => <Object?>[
        plan,
        status,
        productIdentifier,
        expiresAt,
        managementUrl,
      ];
}
