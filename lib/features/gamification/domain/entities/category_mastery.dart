import 'package:equatable/equatable.dart';

enum MasteryTier { none, bronze, silver, gold, platinum }

class CategoryMastery extends Equatable {
  const CategoryMastery({
    required this.categoryId,
    required this.title,
    required this.iconKey,
    required this.totalServings,
    required this.tier,
    required this.nextTierThreshold,
  });

  final String categoryId;
  final String title;
  final String iconKey;
  final int totalServings;
  final MasteryTier tier;
  final int nextTierThreshold;

  bool get hasTier => tier != MasteryTier.none;

  double get progressToNextTier {
    if (tier == MasteryTier.platinum || nextTierThreshold <= 0) {
      return 1;
    }
    final int previousThreshold = _previousThreshold(tier);
    final int span = nextTierThreshold - previousThreshold;
    if (span <= 0) {
      return 1;
    }
    return ((totalServings - previousThreshold) / span).clamp(0, 1).toDouble();
  }

  static int _previousThreshold(MasteryTier tier) {
    return switch (tier) {
      MasteryTier.none => 0,
      MasteryTier.bronze => 10,
      MasteryTier.silver => 50,
      MasteryTier.gold => 150,
      MasteryTier.platinum => 500,
    };
  }

  static MasteryTier tierForServings(int servings) {
    if (servings >= 500) {
      return MasteryTier.platinum;
    }
    if (servings >= 150) {
      return MasteryTier.gold;
    }
    if (servings >= 50) {
      return MasteryTier.silver;
    }
    if (servings >= 10) {
      return MasteryTier.bronze;
    }
    return MasteryTier.none;
  }

  static int nextThresholdForServings(int servings) {
    if (servings >= 500) {
      return 0;
    }
    if (servings >= 150) {
      return 500;
    }
    if (servings >= 50) {
      return 150;
    }
    if (servings >= 10) {
      return 50;
    }
    return 10;
  }

  @override
  List<Object?> get props => <Object?>[
    categoryId,
    title,
    iconKey,
    totalServings,
    tier,
    nextTierThreshold,
  ];
}
