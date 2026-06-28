import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_effect.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';

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
    required this.overview,
    this.pendingEffects = const <GamificationEffect>[],
  });

  final GamificationOverview overview;
  final List<GamificationEffect> pendingEffects;

  GamificationLoaded copyWith({
    GamificationOverview? overview,
    List<GamificationEffect>? pendingEffects,
    bool clearEffects = false,
  }) {
    return GamificationLoaded(
      overview: overview ?? this.overview,
      pendingEffects: clearEffects
          ? const <GamificationEffect>[]
          : pendingEffects ?? this.pendingEffects,
    );
  }

  @override
  List<Object?> get props => <Object?>[overview, pendingEffects];
}

class GamificationError extends GamificationState {
  const GamificationError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
