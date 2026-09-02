enum SubscriptionPlan {
  free,
  monthly,
  annual;

  bool get isPaid => this != SubscriptionPlan.free;

  int get sortOrder {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.monthly:
        return 1;
      case SubscriptionPlan.annual:
        return 2;
    }
  }

  String get revenueCatPackageId {
    switch (this) {
      case SubscriptionPlan.free:
        return 'free';
      case SubscriptionPlan.monthly:
        return r'$rc_monthly';
      case SubscriptionPlan.annual:
        return r'$rc_annual';
    }
  }

  String get periodLabel {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.monthly:
        return 'per month';
      case SubscriptionPlan.annual:
        return 'per year';
    }
  }

  String get savingsLabel {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Daily tracking included';
      case SubscriptionPlan.monthly:
        return 'Flexible monthly plan';
      case SubscriptionPlan.annual:
        return 'Best value · save vs. monthly';
    }
  }

  static SubscriptionPlan fromRevenueCatIdentifier(String identifier) {
    final String normalized = identifier.toLowerCase();
    if (normalized.contains('annual') ||
        normalized.contains('year') ||
        normalized.contains(r'$rc_annual')) {
      return SubscriptionPlan.annual;
    }
    if (normalized.contains('month') || normalized.contains(r'$rc_monthly')) {
      return SubscriptionPlan.monthly;
    }
    return SubscriptionPlan.monthly;
  }
}
