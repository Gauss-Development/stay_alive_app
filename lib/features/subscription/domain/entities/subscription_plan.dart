enum SubscriptionPlan {
  free,
  weekly,
  monthly,
  annual;

  bool get isPaid => this != SubscriptionPlan.free;

  int get sortOrder {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.weekly:
        return 1;
      case SubscriptionPlan.monthly:
        return 2;
      case SubscriptionPlan.annual:
        return 3;
    }
  }

  String get revenueCatPackageId {
    switch (this) {
      case SubscriptionPlan.free:
        return 'free';
      case SubscriptionPlan.weekly:
        return r'$rc_weekly';
      case SubscriptionPlan.monthly:
        return r'$rc_monthly';
      case SubscriptionPlan.annual:
        return r'$rc_annual';
    }
  }

  String get defaultPriceLabel {
    switch (this) {
      case SubscriptionPlan.free:
        return r'$0';
      case SubscriptionPlan.weekly:
        return r'$3';
      case SubscriptionPlan.monthly:
        return r'$15';
      case SubscriptionPlan.annual:
        return r'$100';
    }
  }

  String get periodLabel {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.weekly:
        return 'per week';
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
      case SubscriptionPlan.weekly:
        return 'Flexible starter plan';
      case SubscriptionPlan.monthly:
        return 'Most popular';
      case SubscriptionPlan.annual:
        return 'Best value';
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
    if (normalized.contains('week') || normalized.contains(r'$rc_weekly')) {
      return SubscriptionPlan.weekly;
    }
    return SubscriptionPlan.monthly;
  }
}
