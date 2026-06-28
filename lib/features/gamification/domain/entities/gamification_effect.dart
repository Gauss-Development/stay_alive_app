import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';

abstract class GamificationEffect extends Equatable {
  const GamificationEffect();

  @override
  List<Object?> get props => <Object?>[];
}

class LevelUpEffect extends GamificationEffect {
  const LevelUpEffect(this.level);

  final GameLevel level;

  @override
  List<Object?> get props => <Object?>[level];
}

class BadgeUnlockedEffect extends GamificationEffect {
  const BadgeUnlockedEffect(this.badge);

  final EarnedBadge badge;

  @override
  List<Object?> get props => <Object?>[badge];
}

class ChallengeCompletedEffect extends GamificationEffect {
  const ChallengeCompletedEffect(this.challenge);

  final GamificationChallenge challenge;

  @override
  List<Object?> get props => <Object?>[challenge];
}
