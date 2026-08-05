import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class UserGameProfileModel extends UserGameProfile {
  const UserGameProfileModel({
    required super.userId,
    required super.totalXp,
    required super.currentLevel,
    required super.currentStreak,
    required super.longestStreak,
    required super.activityStreak,
    required super.completedDates,
    required super.earlyLogDates,
    required super.earnedBadges,
    required super.totalCategoriesCompleted,
    super.streakFreezesRemaining,
    super.streakFreezeUsedDates,
  });

  factory UserGameProfileModel.fromProfile(UserGameProfile profile) {
    return UserGameProfileModel(
      userId: profile.userId,
      totalXp: profile.totalXp,
      currentLevel: profile.currentLevel,
      currentStreak: profile.currentStreak,
      longestStreak: profile.longestStreak,
      activityStreak: profile.activityStreak,
      completedDates: profile.completedDates,
      earlyLogDates: profile.earlyLogDates,
      earnedBadges: profile.earnedBadges,
      totalCategoriesCompleted: profile.totalCategoriesCompleted,
      streakFreezesRemaining: profile.streakFreezesRemaining,
      streakFreezeUsedDates: profile.streakFreezeUsedDates,
    );
  }

  factory UserGameProfileModel.fromDocument(appwrite_models.Document document) {
    final Map<String, dynamic> data = document.data;
    final int xp = (data['xp'] as num?)?.toInt() ?? 0;
    final List<String> badgeSlugs =
        (data['badges'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(growable: false);
    final List<String> freezeUsedDates =
        (data['streak_freezes_used'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(growable: false);

    return UserGameProfileModel(
      userId: document.$id,
      totalXp: xp,
      currentLevel: GameLevelTable.forXp(xp),
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['best_streak'] as num?)?.toInt() ?? 0,
      activityStreak: (data['activity_streak'] as num?)?.toInt() ?? 0,
      completedDates: _parseDateList(data['completed_dates_json']),
      earlyLogDates: _parseDateList(data['early_log_dates_json']),
      earnedBadges: badgeSlugs
          .map(_badgeFromLegacySlug)
          .whereType<EarnedBadge>()
          .toList(growable: false),
      totalCategoriesCompleted:
          (data['total_categories_completed'] as num?)?.toInt() ?? 0,
      streakFreezesRemaining:
          (data['streak_freezes_remaining'] as num?)?.toInt() ?? 0,
      streakFreezeUsedDates: freezeUsedDates,
    );
  }

  Map<String, dynamic> toDocumentData({required String now}) {
    return <String, dynamic>{
      'xp': totalXp,
      'level': currentLevel.level,
      'current_streak': currentStreak,
      'best_streak': longestStreak,
      'activity_streak': activityStreak,
      'completed_days': completedDates.length,
      'last_completed_date': completedDates.isEmpty
          ? null
          : completedDates.last,
      'completed_dates_json': completedDates,
      'early_log_dates_json': earlyLogDates,
      'total_categories_completed': totalCategoriesCompleted,
      'streak_freezes_remaining': streakFreezesRemaining,
      'streak_freezes_used': streakFreezeUsedDates,
      'badges': earnedBadges
          .map((EarnedBadge badge) => badge.id.name)
          .toList(growable: false),
      'updated_at': now,
    };
  }

  static List<String> _parseDateList(Object? raw) {
    if (raw is! List<dynamic>) {
      return const <String>[];
    }
    return raw.map((dynamic value) => value.toString()).toList(growable: false);
  }

  static EarnedBadge? _badgeFromLegacySlug(String slug) {
    final BadgeId? badgeId = switch (slug) {
      'firstStep' => BadgeId.firstStep,
      'perfectDay' => BadgeId.perfectDay,
      'weekStreak' => BadgeId.weekStreak,
      'ironWill' => BadgeId.ironWill,
      'earlyBird' => BadgeId.earlyBird,
      'centurion' => BadgeId.centurion,
      'winterWellness' => BadgeId.winterWellness,
      'secretKeeper' => BadgeId.secretKeeper,
      'patron' => BadgeId.patron,
      'firstBloom' => BadgeId.firstBloom,
      'streakGardener' => BadgeId.streakGardener,
      'first_log' => BadgeId.firstStep,
      'perfect_day' => BadgeId.perfectDay,
      'three_day_streak' => null,
      'seven_day_streak' => BadgeId.weekStreak,
      _ => null,
    };
    if (badgeId == null) {
      return null;
    }
    return EarnedBadge(id: badgeId, earnedAt: DateTime.now().toUtc());
  }
}
