import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class GamificationOverviewModel extends GamificationOverview {
  const GamificationOverviewModel({
    required super.profile,
    required super.dailyChallenge,
    required super.weeklyChallenge,
    required super.categoryMastery,
    required super.recentXpEvents,
    super.isPremium,
    super.xpMultiplier,
  });

  factory GamificationOverviewModel.fromOverview(GamificationOverview overview) {
    return GamificationOverviewModel(
      profile: UserGameProfile(
        userId: overview.profile.userId,
        totalXp: overview.profile.totalXp,
        currentLevel: overview.profile.currentLevel,
        currentStreak: overview.profile.currentStreak,
        longestStreak: overview.profile.longestStreak,
        activityStreak: overview.profile.activityStreak,
        completedDates: overview.profile.completedDates,
        earlyLogDates: overview.profile.earlyLogDates,
        earnedBadges: overview.profile.earnedBadges,
        totalCategoriesCompleted: overview.profile.totalCategoriesCompleted,
        streakFreezesRemaining: overview.profile.streakFreezesRemaining,
        streakFreezeUsedDates: overview.profile.streakFreezeUsedDates,
      ),
      dailyChallenge: overview.dailyChallenge,
      weeklyChallenge: overview.weeklyChallenge,
      categoryMastery: overview.categoryMastery,
      recentXpEvents: overview.recentXpEvents,
      isPremium: overview.isPremium,
      xpMultiplier: overview.xpMultiplier,
    );
  }
}
