import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

/// Copy for [CoachLocalFallback], as plain Dart.
///
/// The domain layer must not import Flutter, so it only declares the shape of
/// the text it needs; the data layer fills it in from `AppLocalizations`
/// (see `lib/features/coach/coach_l10n.dart`).
class CoachFallbackStrings {
  const CoachFallbackStrings({
    required this.nudgeWilting,
    required this.nudgeNextStep,
    required this.nudgeAllDone,
    required this.chatIntro,
    required this.chatGaps,
    required this.chatAllDone,
    required this.weeklyMessage,
    required this.weeklyStreakTitle,
    required this.weeklyStreakBody,
    required this.weeklyStreakKeepRhythm,
    required this.weeklyStreakComeBack,
    required this.weeklyGapsTitle,
    required this.weeklyGapsNone,
    required this.weeklyGapsList,
    required this.weeklyAdviceTitle,
    required this.weeklyAdviceBody,
    required this.challengeMessage,
    required this.challengeTitle,
    required this.challengeDescription,
    required this.educationTip,
  });

  final String Function(int streak) nudgeWilting;
  final String Function(int completed, int target, String category)
      nudgeNextStep;
  final String nudgeAllDone;

  final String Function(int streak) chatIntro;
  final String Function(String categories, String levelTitle) chatGaps;
  final String chatAllDone;

  final String weeklyMessage;
  final String weeklyStreakTitle;
  final String Function(int streak, int activityStreak, String levelTitle)
      weeklyStreakBody;
  final String weeklyStreakKeepRhythm;
  final String weeklyStreakComeBack;
  final String weeklyGapsTitle;
  final String weeklyGapsNone;
  final String Function(String categories) weeklyGapsList;
  final String weeklyAdviceTitle;
  final String weeklyAdviceBody;

  final String challengeMessage;
  final String Function(String category) challengeTitle;
  final String Function(String category) challengeDescription;

  final String Function(String category) educationTip;
}

/// Rule-based coach responses used when the ai_coach edge function is unavailable.
abstract final class CoachLocalFallback {
  static CoachResponse respond({
    required CoachMode mode,
    required CoachContextPayload context,
    required CoachFallbackStrings strings,
  }) {
    return switch (mode) {
      CoachMode.nudge => _nudge(context, strings),
      CoachMode.chat => _chat(context, strings),
      CoachMode.weeklyInsight => _weekly(context, strings),
      CoachMode.personalizeChallenge => _challenge(context, strings),
      CoachMode.educationTip => _education(context, strings),
    };
  }

  static CoachResponse _nudge(
    CoachContextPayload context,
    CoachFallbackStrings strings,
  ) {
    if (context.wilting) {
      return CoachResponse(
        message: strings.nudgeWilting(context.streak),
        fromFallback: true,
      );
    }
    if (context.incompleteCategories.isNotEmpty) {
      return CoachResponse(
        message: strings.nudgeNextStep(
          context.todayCompleted,
          context.todayTarget,
          context.incompleteCategories.first,
        ),
        fromFallback: true,
      );
    }
    return CoachResponse(
      message: strings.nudgeAllDone,
      fromFallback: true,
    );
  }

  static CoachResponse _chat(
    CoachContextPayload context,
    CoachFallbackStrings strings,
  ) {
    final String ask = context.userMessage?.trim() ?? '';
    if (ask.isEmpty) {
      return CoachResponse(
        message: strings.chatIntro(context.streak),
        fromFallback: true,
      );
    }
    if (context.incompleteCategories.isNotEmpty) {
      return CoachResponse(
        message: strings.chatGaps(
          context.incompleteCategories.join(', '),
          context.levelTitle,
        ),
        fromFallback: true,
      );
    }
    return CoachResponse(
      message: strings.chatAllDone,
      fromFallback: true,
    );
  }

  static CoachResponse _weekly(
    CoachContextPayload context,
    CoachFallbackStrings strings,
  ) {
    return CoachResponse(
      message: strings.weeklyMessage,
      insightCards: <WeeklyInsightCard>[
        WeeklyInsightCard(
          title: strings.weeklyStreakTitle,
          body: strings.weeklyStreakBody(
            context.streak,
            context.activityStreak,
            context.levelTitle,
          ),
          emphasis: context.streak > 0
              ? strings.weeklyStreakKeepRhythm
              : strings.weeklyStreakComeBack,
        ),
        WeeklyInsightCard(
          title: strings.weeklyGapsTitle,
          body: context.incompleteCategories.isEmpty
              ? strings.weeklyGapsNone
              : strings.weeklyGapsList(
                  context.incompleteCategories.take(3).join(', '),
                ),
        ),
        WeeklyInsightCard(
          title: strings.weeklyAdviceTitle,
          body: context.weekSummary ?? strings.weeklyAdviceBody,
        ),
      ],
      fromFallback: true,
    );
  }

  static CoachResponse _challenge(
    CoachContextPayload context,
    CoachFallbackStrings strings,
  ) {
    final String focus = context.incompleteCategories.isNotEmpty
        ? context.incompleteCategories.first
        : 'greens';
    return CoachResponse(
      message: strings.challengeMessage,
      challengeDraft: PersonalizedChallengeDraft(
        title: strings.challengeTitle(focus),
        description: strings.challengeDescription(focus),
        target: 1,
        xpReward: 45,
        categoryId: focus,
        challengeType: 'completeCategory',
      ).validated(),
      fromFallback: true,
    );
  }

  static CoachResponse _education(
    CoachContextPayload context,
    CoachFallbackStrings strings,
  ) {
    return CoachResponse(
      message: strings.educationTip(context.categoryId ?? 'greens'),
      fromFallback: true,
    );
  }
}
