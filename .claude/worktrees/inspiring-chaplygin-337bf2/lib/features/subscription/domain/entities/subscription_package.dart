import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_plan.dart';

class SubscriptionPackage extends Equatable {
  const SubscriptionPackage({
    required this.id,
    required this.plan,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.productIdentifier,
  });

  final String id;
  final SubscriptionPlan plan;
  final String title;
  final String description;
  final String priceLabel;
  final String productIdentifier;

  String get periodLabel => plan.periodLabel;
  String get savingsLabel => plan.savingsLabel;

  @override
  List<Object?> get props => <Object?>[
        id,
        plan,
        title,
        description,
        priceLabel,
        productIdentifier,
      ];
}
