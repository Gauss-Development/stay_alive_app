import 'package:equatable/equatable.dart';

class SubscriptionInfo extends Equatable {
  const SubscriptionInfo({
    required this.plan,
    required this.status,
    this.expiresAt,
  });

  final String plan;
  final String status;
  final DateTime? expiresAt;

  bool get isPremiumActive => status == 'active';

  @override
  List<Object?> get props => <Object?>[plan, status, expiresAt];
}
