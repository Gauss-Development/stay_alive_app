import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_effect.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_overview_usecase.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_params.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_today_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit({
    required ReconcileGamificationOverviewUseCase
    reconcileGamificationOverviewUseCase,
    required ReconcileGamificationTodayUseCase
    reconcileGamificationTodayUseCase,
    GamificationEngine? engine,
  }) : _reconcileGamificationOverviewUseCase =
           reconcileGamificationOverviewUseCase,
       _reconcileGamificationTodayUseCase = reconcileGamificationTodayUseCase,
       _engine = engine ?? const GamificationEngine(),
       super(const GamificationInitial());

  final ReconcileGamificationOverviewUseCase
  _reconcileGamificationOverviewUseCase;
  final ReconcileGamificationTodayUseCase _reconcileGamificationTodayUseCase;
  final GamificationEngine _engine;

  PersonalizedChallengeDraft? _aiDailyDraft;

  PersonalizedChallengeDraft? get aiDailyDraft => _aiDailyDraft;

  /// Applies a premium AI daily quest; next reconcile uses it for XP.
  void setAiDailyDraft(PersonalizedChallengeDraft? draft) {
    _aiDailyDraft = draft?.validated();
  }

  Future<void> load({required bool isPremium}) async {
    emit(const GamificationLoading());
    await _reconcile(
      isPremium: isPremium,
      emitLoadingState: false,
      useTodayPath: false,
    );
  }

  Future<void> refresh({required bool isPremium}) async {
    await _reconcile(
      isPremium: isPremium,
      emitLoadingState: state is! GamificationLoaded,
      useTodayPath: false,
    );
  }

  Future<void> refreshToday({
    required DailyLog todayLog,
    required bool isPremium,
  }) async {
    await _reconcile(
      isPremium: isPremium,
      emitLoadingState: false,
      useTodayPath: true,
      todayLog: todayLog,
    );
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

  Future<void> _reconcile({
    required bool isPremium,
    required bool emitLoadingState,
    required bool useTodayPath,
    DailyLog? todayLog,
  }) async {
    if (emitLoadingState) {
      emit(const GamificationLoading());
    }

    final GamificationOverview? previousOverview = switch (state) {
      GamificationLoaded(overview: final GamificationOverview overview) =>
        overview,
      _ => null,
    };

    final PersonalizedChallengeDraft? draft =
        isPremium ? _aiDailyDraft : null;

    final result = useTodayPath && todayLog != null
        ? await _reconcileGamificationTodayUseCase(
            ReconcileGamificationTodayParams(
              todayLog: todayLog,
              isPremium: isPremium,
              personalizedDailyDraft: draft,
            ),
          )
        : await _reconcileGamificationOverviewUseCase(
            ReconcileGamificationParams(
              isPremium: isPremium,
              personalizedDailyDraft: draft,
            ),
          );

    result.fold((failure) => emit(GamificationError(failure.message)), (
      GamificationOverview overview,
    ) {
      final List<GamificationEffect> effects = _mapEffects(
        previousOverview,
        overview,
      );
      emit(GamificationLoaded(overview: overview, pendingEffects: effects));
    });
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

    if (!previous.weeklyChallenge.isCompleted &&
        next.weeklyChallenge.isCompleted &&
        (!next.weeklyChallenge.isPremiumOnly || next.isPremium)) {
      effects.add(WeeklyChallengeCompletedEffect(next.weeklyChallenge));
    }

    return effects;
  }

  List<GamificationEffect> _mapEngineEffects(
    List<GamificationEffectCandidate> candidates,
  ) {
    return candidates
        .map((GamificationEffectCandidate candidate) {
          return switch (candidate) {
            LevelUpEffectCandidate(level: final level) => LevelUpEffect(level),
            BadgeUnlockedEffectCandidate(badge: final badge) =>
              BadgeUnlockedEffect(badge),
          };
        })
        .toList(growable: false);
  }
}
