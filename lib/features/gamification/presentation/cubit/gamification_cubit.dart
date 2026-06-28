import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_effect.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_overview_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit({
    required ReconcileGamificationOverviewUseCase
        reconcileGamificationOverviewUseCase,
    GamificationEngine? engine,
  })  : _reconcileGamificationOverviewUseCase =
            reconcileGamificationOverviewUseCase,
        _engine = engine ?? const GamificationEngine(),
        super(const GamificationInitial());

  final ReconcileGamificationOverviewUseCase
      _reconcileGamificationOverviewUseCase;
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

    final GamificationOverview? previousOverview = switch (state) {
      GamificationLoaded(overview: final GamificationOverview overview) =>
        overview,
      _ => null,
    };

    final result =
        await _reconcileGamificationOverviewUseCase(const NoParams());
    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (GamificationOverview overview) {
        final List<GamificationEffect> effects = _mapEffects(
          previousOverview,
          overview,
        );
        emit(
          GamificationLoaded(
            overview: overview,
            pendingEffects: effects,
          ),
        );
      },
    );
  }

  List<GamificationEffect> _mapEffects(
    GamificationOverview? previous,
    GamificationOverview next,
  ) {
    if (previous == null) {
      return const <GamificationEffect>[];
    }

    final List<GamificationEffect> effects = _mapEngineEffects(
      _engine.diffProfiles(previous.profile, next.profile),
    );

    if (!previous.dailyChallenge.isCompleted &&
        next.dailyChallenge.isCompleted) {
      effects.add(ChallengeCompletedEffect(next.dailyChallenge));
    }

    return effects;
  }

  List<GamificationEffect> _mapEngineEffects(
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
