import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class GamificationOverviewModel extends GamificationOverview {
  const GamificationOverviewModel({
    required super.profile,
    required super.dailyChallenge,
    required super.categoryMastery,
    required super.recentXpEvents,
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
      ),
      dailyChallenge: overview.dailyChallenge,
      categoryMastery: overview.categoryMastery,
      recentXpEvents: overview.recentXpEvents,
    );
  }
}
