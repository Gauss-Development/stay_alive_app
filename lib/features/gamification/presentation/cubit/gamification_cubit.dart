import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_effect.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_progress_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit({
    required ReconcileGamificationProgressUseCase
        reconcileGamificationProgressUseCase,
    GamificationEngine? engine,
  })  : _reconcileGamificationProgressUseCase =
            reconcileGamificationProgressUseCase,
        _engine = engine ?? const GamificationEngine(),
        super(const GamificationInitial());

  final ReconcileGamificationProgressUseCase
      _reconcileGamificationProgressUseCase;
  final GamificationEngine _engine;

  Future<void> load() async {
    emit(const GamificationLoading());
    await _reconcile(emitLoadingState: false);
  }

  Future<void> refresh() async {
    await _reconcile(emitLoadingState: state is! GamificationLoaded);
  }

  void clearEffects() {
    final GamificationState current = state;
    if (current is GamificationLoaded) {
      emit(current.copyWith(clearEffects: true));
    }
  }

  void dismissEffect(GamificationEffect effect) {
    final GamificationState current = state;
    if (current is! GamificationLoaded) {
      return;
    }
    final List<GamificationEffect> remaining = current.pendingEffects
        .where((GamificationEffect item) => item != effect)
        .toList(growable: false);
    emit(current.copyWith(pendingEffects: remaining));
  }

  Future<void> _reconcile({required bool emitLoadingState}) async {
    if (emitLoadingState) {
      emit(const GamificationLoading());
    }

    final UserGameProfile? previousProfile = switch (state) {
      GamificationLoaded(profile: final UserGameProfile profile) => profile,
      _ => null,
    };

    final result = await _reconcileGamificationProgressUseCase(const NoParams());
    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (UserGameProfile profile) {
        final List<GamificationEffect> effects = _mapEffects(
          _engine.diffProfiles(previousProfile, profile),
        );
        emit(
          GamificationLoaded(
            profile: profile,
            pendingEffects: effects,
          ),
        );
      },
    );
  }

  List<GamificationEffect> _mapEffects(
    List<GamificationEffectCandidate> candidates,
  ) {
    return candidates.map((GamificationEffectCandidate candidate) {
      return switch (candidate) {
        LevelUpEffectCandidate(level: final level) => LevelUpEffect(level),
        BadgeUnlockedEffectCandidate(badge: final badge) =>
          BadgeUnlockedEffect(badge),
      };
    }).toList(growable: false);
  }
}
