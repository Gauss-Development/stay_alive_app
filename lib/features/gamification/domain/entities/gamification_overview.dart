import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class GamificationOverview extends Equatable {
  const GamificationOverview({
    required this.profile,
    required this.dailyChallenge,
    required this.weeklyChallenge,
    required this.categoryMastery,
    required this.recentXpEvents,
    this.isPremium = false,
    this.xpMultiplier = 1,
  });

  final UserGameProfile profile;
  final GamificationChallenge dailyChallenge;
  final GamificationChallenge weeklyChallenge;
  final List<CategoryMastery> categoryMastery;
  final List<GamificationXpEvent> recentXpEvents;
  final bool isPremium;
  final double xpMultiplier;

  List<BadgeGalleryItem> get badgeGallery {
    final Set<BadgeId> earnedIds = profile.earnedBadges
        .map((EarnedBadge badge) => badge.id)
        .toSet();
    final Map<BadgeId, EarnedBadge> earnedById = <BadgeId, EarnedBadge>{
      for (final EarnedBadge badge in profile.earnedBadges) badge.id: badge,
    };

    return BadgeId.values
        .where((BadgeId id) {
          final BadgeDefinition definition = BadgeDefinition.all[id]!;
          if (definition.isHidden && !earnedIds.contains(id)) {
            return false;
          }
          return true;
        })
        .map((BadgeId id) {
          final EarnedBadge? earned = earnedById[id];
          return BadgeGalleryItem(
            definition: BadgeDefinition.all[id]!,
            earnedAt: earned?.earnedAt,
            isUnlocked: earnedIds.contains(id),
          );
        })
        .toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[
    profile,
    dailyChallenge,
    weeklyChallenge,
    categoryMastery,
    recentXpEvents,
    isPremium,
    xpMultiplier,
  ];
}

class BadgeGalleryItem extends Equatable {
  const BadgeGalleryItem({
    required this.definition,
    required this.isUnlocked,
    this.earnedAt,
  });

  final BadgeDefinition definition;
  final bool isUnlocked;
  final DateTime? earnedAt;

  @override
  List<Object?> get props => <Object?>[definition, isUnlocked, earnedAt];
}
