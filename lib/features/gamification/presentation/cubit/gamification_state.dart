import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_effect.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => <Object?>[];
}

class GamificationInitial extends GamificationState {
  const GamificationInitial();
}

class GamificationLoading extends GamificationState {
  const GamificationLoading();
}

class GamificationLoaded extends GamificationState {
  const GamificationLoaded({
    required this.profile,
    this.pendingEffects = const <GamificationEffect>[],
  });

  final UserGameProfile profile;
  final List<GamificationEffect> pendingEffects;

  GamificationLoaded copyWith({
    UserGameProfile? profile,
    List<GamificationEffect>? pendingEffects,
    bool clearEffects = false,
  }) {
    return GamificationLoaded(
      profile: profile ?? this.profile,
      pendingEffects: clearEffects
          ? const <GamificationEffect>[]
          : pendingEffects ?? this.pendingEffects,
    );
  }

  @override
  List<Object?> get props => <Object?>[profile, pendingEffects];
}

class GamificationError extends GamificationState {
  const GamificationError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
