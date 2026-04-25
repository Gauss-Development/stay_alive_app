import 'package:equatable/equatable.dart';

enum BadgeId {
  firstStep,
  perfectDay,
  weekStreak,
  ironWill,
  earlyBird,
  centurion,
}

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });

  final BadgeId id;
  final String name;
  final String description;
  final String emoji;

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
