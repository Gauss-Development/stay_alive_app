import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';

class UserGameProfile extends Equatable {
  const UserGameProfile({
    required this.userId,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.activityStreak,
    required this.completedDates,
    required this.earlyLogDates,
    required this.earnedBadges,
    required this.totalCategoriesCompleted,
    this.streakFreezesRemaining = 0,
    this.streakFreezeUsedDates = const <String>[],
  });

  const UserGameProfile.empty()
    : userId = '',
      totalXp = 0,
      currentLevel = const GameLevel(
        level: 1,
        title: 'Seedling',
        xpRequired: 0,
        xpForNext: 500,
      ),
      currentStreak = 0,
      longestStreak = 0,
      activityStreak = 0,
      completedDates = const <String>[],
      earlyLogDates = const <String>[],
      earnedBadges = const <EarnedBadge>[],
      totalCategoriesCompleted = 0,
      streakFreezesRemaining = 0,
      streakFreezeUsedDates = const <String>[];

  final String userId;
  final int totalXp;
  final GameLevel currentLevel;
  final int currentStreak;
  final int longestStreak;
  final int activityStreak;

  /// Fully completed days as 'yyyy-MM-dd', sorted ascending.
  final List<String> completedDates;

  /// Days where any item was logged before 9 AM, as 'yyyy-MM-dd'.
  final List<String> earlyLogDates;

  final List<EarnedBadge> earnedBadges;
  final int totalCategoriesCompleted;
  final int streakFreezesRemaining;

  /// Missed dates bridged by a streak freeze, as 'yyyy-MM-dd'.
  final List<String> streakFreezeUsedDates;

  UserGameProfile copyWith({
    String? userId,
    int? totalXp,
    GameLevel? currentLevel,
    int? currentStreak,
    int? longestStreak,
    int? activityStreak,
    List<String>? completedDates,
    List<String>? earlyLogDates,
    List<EarnedBadge>? earnedBadges,
    int? totalCategoriesCompleted,
    int? streakFreezesRemaining,
    List<String>? streakFreezeUsedDates,
  }) {
    return UserGameProfile(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      activityStreak: activityStreak ?? this.activityStreak,
      completedDates: completedDates ?? this.completedDates,
      earlyLogDates: earlyLogDates ?? this.earlyLogDates,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      totalCategoriesCompleted:
          totalCategoriesCompleted ?? this.totalCategoriesCompleted,
      streakFreezesRemaining:
          streakFreezesRemaining ?? this.streakFreezesRemaining,
      streakFreezeUsedDates:
          streakFreezeUsedDates ?? this.streakFreezeUsedDates,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    userId,
    totalXp,
    currentLevel,
    currentStreak,
    longestStreak,
    activityStreak,
    completedDates,
    earlyLogDates,
    earnedBadges,
    totalCategoriesCompleted,
    streakFreezesRemaining,
    streakFreezeUsedDates,
  ];
}
