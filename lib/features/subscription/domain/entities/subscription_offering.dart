import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';

class SubscriptionOffering extends Equatable {
  const SubscriptionOffering({
    required this.packages,
    this.isConfigured = true,
  });

  const SubscriptionOffering.empty()
    : packages = const <SubscriptionPackage>[],
      isConfigured = false;

  final List<SubscriptionPackage> packages;
  final bool isConfigured;

  bool get hasPackages => packages.isNotEmpty;

  SubscriptionPackage? packageForId(String id) {
    for (final SubscriptionPackage package in packages) {
      if (package.id == id) {
        return package;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[packages, isConfigured];
}
