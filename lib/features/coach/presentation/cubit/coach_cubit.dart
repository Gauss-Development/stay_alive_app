import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/domain/usecases/invoke_coach_usecase.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  CoachCubit(this._invokeCoach) : super(const CoachInitial());

  final InvokeCoachUseCase _invokeCoach;

  CoachLoaded get _loadedOrEmpty => state is CoachLoaded
      ? state as CoachLoaded
      : const CoachLoaded(messages: <CoachMessage>[]);

  Future<void> requestNudge({
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    final CoachLoaded current = _loadedOrEmpty;
    if (!isPremium && !current.canNudgeFree) {
      emit(
        current.copyWith(
          errorMessage: 'Дневной лимит подсказок исчерпан. Открой Pro-чат.',
        ),
      );
      return;
    }

    final result = await _invokeCoach(
      InvokeCoachParams(
        mode: CoachMode.nudge,
        context: context,
        isPremium: isPremium,
      ),
    );
    result.fold(
      (failure) => emit(current.copyWith(errorMessage: failure.message)),
      (response) {
        emit(
          current.copyWith(
            lastNudge: response,
            freeNudgesUsedToday: isPremium
                ? current.freeNudgesUsedToday
                : current.freeNudgesUsedToday + 1,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> sendChat({
    required String message,
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    final CoachLoaded current = _loadedOrEmpty;
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final List<CoachMessage> nextMessages = List<CoachMessage>.of(
      current.messages,
    )..add(
        CoachMessage(
          role: 'user',
          text: trimmed,
          createdAt: DateTime.now().toUtc(),
        ),
      );

    emit(current.copyWith(messages: nextMessages, clearError: true));
    emit(const CoachLoading());

    final result = await _invokeCoach(
      InvokeCoachParams(
        mode: CoachMode.chat,
        context: CoachContextPayload(
          level: context.level,
          levelTitle: context.levelTitle,
          streak: context.streak,
          activityStreak: context.activityStreak,
          todayCompleted: context.todayCompleted,
          todayTarget: context.todayTarget,
          incompleteCategories: context.incompleteCategories,
          wilting: context.wilting,
          userMessage: trimmed,
          weekSummary: context.weekSummary,
        ),
        isPremium: isPremium,
      ),
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          messages: nextMessages,
          errorMessage: failure.message,
        ),
      ),
      (response) {
        emit(
          current.copyWith(
            messages: <CoachMessage>[
              ...nextMessages,
              CoachMessage(
                role: 'assistant',
                text: response.message,
                createdAt: DateTime.now().toUtc(),
                suggestedActions: response.suggestedActions,
              ),
            ],
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> loadWeeklyInsights({
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    final CoachLoaded current = _loadedOrEmpty;
    emit(const CoachLoading());
    final result = await _invokeCoach(
      InvokeCoachParams(
        mode: CoachMode.weeklyInsight,
        context: context,
        isPremium: isPremium,
      ),
    );
    result.fold(
      (failure) => emit(current.copyWith(errorMessage: failure.message)),
      (response) => emit(
        current.copyWith(
          weeklyInsights: response.insightCards,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> personalizeChallenge({
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    final CoachLoaded current = _loadedOrEmpty;
    final result = await _invokeCoach(
      InvokeCoachParams(
        mode: CoachMode.personalizeChallenge,
        context: context,
        isPremium: isPremium,
      ),
    );
    result.fold(
      (failure) => emit(current.copyWith(errorMessage: failure.message)),
      (response) => emit(
        current.copyWith(
          challengeDraft: response.challengeDraft,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> loadEducationTip({
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    final CoachLoaded current = _loadedOrEmpty;
    final result = await _invokeCoach(
      InvokeCoachParams(
        mode: CoachMode.educationTip,
        context: context,
        isPremium: isPremium,
      ),
    );
    result.fold(
      (failure) => emit(current.copyWith(errorMessage: failure.message)),
      (response) => emit(
        current.copyWith(educationTip: response.message, clearError: true),
      ),
    );
  }

  void dismissNudge() {
    final CoachState current = state;
    if (current is CoachLoaded) {
      emit(
        CoachLoaded(
          messages: current.messages,
          weeklyInsights: current.weeklyInsights,
          challengeDraft: current.challengeDraft,
          educationTip: current.educationTip,
          freeNudgesUsedToday: current.freeNudgesUsedToday,
        ),
      );
    }
  }
}
