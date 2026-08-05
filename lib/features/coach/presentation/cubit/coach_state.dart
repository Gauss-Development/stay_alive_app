import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

abstract class CoachState extends Equatable {
  const CoachState();

  @override
  List<Object?> get props => <Object?>[];
}

class CoachInitial extends CoachState {
  const CoachInitial();
}

class CoachLoading extends CoachState {
  const CoachLoading();
}

class CoachLoaded extends CoachState {
  const CoachLoaded({
    required this.messages,
    this.lastNudge,
    this.weeklyInsights = const <WeeklyInsightCard>[],
    this.challengeDraft,
    this.educationTip,
    this.freeNudgesUsedToday = 0,
    this.errorMessage,
  });

  final List<CoachMessage> messages;
  final CoachResponse? lastNudge;
  final List<WeeklyInsightCard> weeklyInsights;
  final PersonalizedChallengeDraft? challengeDraft;
  final String? educationTip;
  final int freeNudgesUsedToday;
  final String? errorMessage;

  static const int freeNudgeDailyLimit = 5;

  bool get canNudgeFree => freeNudgesUsedToday < freeNudgeDailyLimit;

  CoachLoaded copyWith({
    List<CoachMessage>? messages,
    CoachResponse? lastNudge,
    List<WeeklyInsightCard>? weeklyInsights,
    PersonalizedChallengeDraft? challengeDraft,
    String? educationTip,
    int? freeNudgesUsedToday,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoachLoaded(
      messages: messages ?? this.messages,
      lastNudge: lastNudge ?? this.lastNudge,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      challengeDraft: challengeDraft ?? this.challengeDraft,
      educationTip: educationTip ?? this.educationTip,
      freeNudgesUsedToday: freeNudgesUsedToday ?? this.freeNudgesUsedToday,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        messages,
        lastNudge,
        weeklyInsights,
        challengeDraft,
        educationTip,
        freeNudgesUsedToday,
        errorMessage,
      ];
}

class CoachError extends CoachState {
  const CoachError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
