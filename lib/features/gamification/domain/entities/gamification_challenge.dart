import 'package:equatable/equatable.dart';

enum ChallengeType {
  closeCategories,
  logServings,
  earlyLog,
  completeCategory,
  perfectDay,
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
    this.categoryId,
  });

  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int xpReward;
  final String dateKey;
  final String? categoryId;

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
        categoryId,
      ];
}
