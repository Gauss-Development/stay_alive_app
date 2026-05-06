import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';

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
  const GamificationLoaded(this.progress);

  final GamificationProgress progress;

  @override
  List<Object?> get props => <Object?>[progress];
}

class GamificationError extends GamificationState {
  const GamificationError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
