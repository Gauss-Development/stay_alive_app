import 'package:equatable/equatable.dart';

enum ChallengeType {
  closeCategories,
  logServings,
  earlyLog,
  completeCategory,
  perfectDay,
  perfectDaysInWeek,
  activeDaysInWeek,
}

enum ChallengePeriod {
  daily,
  weekly,
}

class GamificationChallenge extends Equatable {
  const GamificationChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.xpReward,
    required this.dateKey,
    this.period = ChallengePeriod.daily,
    this.categoryId,
    this.isPremiumOnly = false,
  });

  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int xpReward;
  final String dateKey;
  final ChallengePeriod period;
  final String? categoryId;
  final bool isPremiumOnly;

  bool get isCompleted => progress >= target && target > 0;

  double get progressFraction {
    if (target <= 0) {
      return 0;
    }
    return (progress / target).clamp(0, 1).toDouble();
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        type,
        title,
        description,
        target,
        progress,
        xpReward,
        dateKey,
        period,
        categoryId,
        isPremiumOnly,
      ];
}
