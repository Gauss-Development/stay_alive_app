import 'package:equatable/equatable.dart';

class GamificationProgress extends Equatable {
  const GamificationProgress({
    required this.userId,
    required this.xp,
    required this.level,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.currentStreak,
    required this.bestStreak,
    required this.completedDays,
    required this.lastCompletedDate,
    required this.badges,
  });

  final String userId;
  final int xp;
  final int level;
  final int currentLevelXp;
  final int nextLevelXp;
  final int currentStreak;
  final int bestStreak;
  final int completedDays;
  final String? lastCompletedDate;
  final List<String> badges;

  double get levelProgress {
    final int levelSpan = nextLevelXp - currentLevelXp;
    if (levelSpan <= 0) {
      return 0;
    }
    return ((xp - currentLevelXp) / levelSpan).clamp(0, 1).toDouble();
  }

  @override
  List<Object?> get props => <Object?>[
        userId,
        xp,
        level,
        currentLevelXp,
        nextLevelXp,
        currentStreak,
        bestStreak,
        completedDays,
        lastCompletedDate,
        badges,
      ];
}
