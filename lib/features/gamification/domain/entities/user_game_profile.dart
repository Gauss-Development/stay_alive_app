import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';

class UserGameProfile extends Equatable {
  const UserGameProfile({
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDates,
    required this.earlyLogDates,
    required this.earnedBadges,
    required this.totalCategoriesCompleted,
  });

  const UserGameProfile.empty()
      : totalXp = 0,
        currentLevel = const GameLevel(
          level: 1,
          title: 'Seedling',
          xpRequired: 0,
          xpForNext: 500,
        ),
        currentStreak = 0,
        longestStreak = 0,
        completedDates = const <String>[],
        earlyLogDates = const <String>[],
        earnedBadges = const <EarnedBadge>[],
        totalCategoriesCompleted = 0;

  final int totalXp;
  final GameLevel currentLevel;
  final int currentStreak;
  final int longestStreak;

  /// Fully completed days as 'yyyy-MM-dd', sorted ascending.
  final List<String> completedDates;

  /// Days where any item was logged before 9 AM, as 'yyyy-MM-dd'.
  final List<String> earlyLogDates;

  final List<EarnedBadge> earnedBadges;
  final int totalCategoriesCompleted;

  UserGameProfile copyWith({
    int? totalXp,
    GameLevel? currentLevel,
    int? currentStreak,
    int? longestStreak,
    List<String>? completedDates,
    List<String>? earlyLogDates,
    List<EarnedBadge>? earnedBadges,
    int? totalCategoriesCompleted,
  }) {
    return UserGameProfile(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedDates: completedDates ?? this.completedDates,
      earlyLogDates: earlyLogDates ?? this.earlyLogDates,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      totalCategoriesCompleted:
          totalCategoriesCompleted ?? this.totalCategoriesCompleted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        totalXp,
        currentLevel,
        currentStreak,
        longestStreak,
        completedDates,
        earlyLogDates,
        earnedBadges,
        totalCategoriesCompleted,
      ];
}
