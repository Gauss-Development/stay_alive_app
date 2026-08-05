import 'package:equatable/equatable.dart';

enum BadgeId {
  firstStep,
  perfectDay,
  weekStreak,
  ironWill,
  earlyBird,
  centurion,
  winterWellness,
  secretKeeper,
  patron,
  firstBloom,
  streakGardener,
}

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.isHidden = false,
    this.availableFromMonth,
    this.availableUntilMonth,
    this.requiresPremium = false,
  });

  final BadgeId id;
  final String name;
  final String description;
  final String emoji;
  final bool isHidden;

  /// Inclusive seasonal start month (1-12). Null means always available.
  final int? availableFromMonth;

  /// Inclusive seasonal end month (1-12). Null means always available.
  final int? availableUntilMonth;
  final bool requiresPremium;

  bool isAvailableOn(DateTime date) {
    if (availableFromMonth == null || availableUntilMonth == null) {
      return true;
    }

    final int month = date.month;
    final int from = availableFromMonth!;
    final int until = availableUntilMonth!;

    if (from <= until) {
      return month >= from && month <= until;
    }

    return month >= from || month <= until;
  }

  String get lockedDisplayName => isHidden ? '???' : name;

  static const Map<BadgeId, BadgeDefinition> all = <BadgeId, BadgeDefinition>{
    BadgeId.firstStep: BadgeDefinition(
      id: BadgeId.firstStep,
      name: 'First Step',
      description: 'Complete your very first daily category.',
      emoji: '🌱',
    ),
    BadgeId.perfectDay: BadgeDefinition(
      id: BadgeId.perfectDay,
      name: 'Perfect Day',
      description: 'Complete all Daily Dozen in a single day.',
      emoji: '⭐',
    ),
    BadgeId.weekStreak: BadgeDefinition(
      id: BadgeId.weekStreak,
      name: 'Week Warrior',
      description: 'Maintain a 7-day completion streak.',
      emoji: '🔥',
    ),
    BadgeId.ironWill: BadgeDefinition(
      id: BadgeId.ironWill,
      name: 'Iron Will',
      description: 'Maintain a 30-day completion streak.',
      emoji: '💪',
    ),
    BadgeId.earlyBird: BadgeDefinition(
      id: BadgeId.earlyBird,
      name: 'Early Bird',
      description: 'Log before 9 AM on 5 different days.',
      emoji: '🌅',
    ),
    BadgeId.centurion: BadgeDefinition(
      id: BadgeId.centurion,
      name: 'Centurion',
      description: 'Fully complete 100 days.',
      emoji: '🏆',
    ),
    BadgeId.winterWellness: BadgeDefinition(
      id: BadgeId.winterWellness,
      name: 'Winter Wellness',
      description: 'Complete 5 perfect days during winter.',
      emoji: '❄️',
      availableFromMonth: 12,
      availableUntilMonth: 2,
    ),
    BadgeId.secretKeeper: BadgeDefinition(
      id: BadgeId.secretKeeper,
      name: 'Secret Keeper',
      description: 'Maintain a hidden 14-day perfect streak.',
      emoji: '🗝️',
      isHidden: true,
    ),
    BadgeId.patron: BadgeDefinition(
      id: BadgeId.patron,
      name: 'Patron',
      description: 'Support the app with an active premium membership.',
      emoji: '💎',
      requiresPremium: true,
    ),
    BadgeId.firstBloom: BadgeDefinition(
      id: BadgeId.firstBloom,
      name: 'First Bloom',
      description: 'Grow your sprout to Vitalist (bloom stage).',
      emoji: '🌸',
    ),
    BadgeId.streakGardener: BadgeDefinition(
      id: BadgeId.streakGardener,
      name: 'Streak Gardener',
      description: 'Keep an activity streak of 7 days.',
      emoji: '🪴',
    ),
  };
}

class EarnedBadge extends Equatable {
  const EarnedBadge({required this.id, required this.earnedAt});

  final BadgeId id;
  final DateTime earnedAt;

  BadgeDefinition get definition => BadgeDefinition.all[id]!;

  @override
  List<Object?> get props => <Object?>[id, earnedAt];
}
