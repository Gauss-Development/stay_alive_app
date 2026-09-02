import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

/// Compact context sent to the AI coach function.
class CoachContextPayload extends Equatable {
  const CoachContextPayload({
    required this.level,
    required this.levelTitle,
    required this.streak,
    required this.activityStreak,
    required this.todayCompleted,
    required this.todayTarget,
    required this.incompleteCategories,
    required this.wilting,
    this.categoryId,
    this.userMessage,
    this.weekSummary,
  });

  final int level;
  final String levelTitle;
  final int streak;
  final int activityStreak;
  final int todayCompleted;
  final int todayTarget;
  final List<String> incompleteCategories;
  final bool wilting;
  final String? categoryId;
  final String? userMessage;
  final String? weekSummary;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'level': level,
        'levelTitle': levelTitle,
        'streak': streak,
        'activityStreak': activityStreak,
        'todayCompleted': todayCompleted,
        'todayTarget': todayTarget,
        'incompleteCategories': incompleteCategories,
        'wilting': wilting,
        if (categoryId != null) 'categoryId': categoryId,
        if (userMessage != null) 'userMessage': userMessage,
        if (weekSummary != null) 'weekSummary': weekSummary,
      };

  @override
  List<Object?> get props => <Object?>[
        level,
        levelTitle,
        streak,
        activityStreak,
        todayCompleted,
        todayTarget,
        incompleteCategories,
        wilting,
        categoryId,
        userMessage,
        weekSummary,
      ];
}

enum CoachMode { nudge, chat, weeklyInsight, personalizeChallenge, educationTip }

class CoachMessage extends Equatable {
  const CoachMessage({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String role;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[role, text, createdAt];
}

class WeeklyInsightCard extends Equatable {
  const WeeklyInsightCard({
    required this.title,
    required this.body,
    this.emphasis,
  });

  final String title;
  final String body;
  final String? emphasis;

  factory WeeklyInsightCard.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightCard(
      // Untitled cards are labelled by the widget — the domain stays language-free.
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      emphasis: json['emphasis']?.toString(),
    );
  }

  @override
  List<Object?> get props => <Object?>[title, body, emphasis];
}

class CoachResponse extends Equatable {
  const CoachResponse({
    required this.message,
    this.insightCards = const <WeeklyInsightCard>[],
    this.challengeDraft,
    this.fromFallback = false,
  });

  final String message;
  final List<WeeklyInsightCard> insightCards;
  final PersonalizedChallengeDraft? challengeDraft;
  final bool fromFallback;

  factory CoachResponse.fromJson(Map<String, dynamic> json) {
    final List<WeeklyInsightCard> cards = <WeeklyInsightCard>[];
    final Object? rawCards = json['insightCards'];
    if (rawCards is List<dynamic>) {
      for (final Object? item in rawCards) {
        if (item is Map<String, dynamic>) {
          cards.add(WeeklyInsightCard.fromJson(item));
        } else if (item is Map) {
          cards.add(
            WeeklyInsightCard.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    PersonalizedChallengeDraft? draft;
    final Object? rawDraft = json['challengeDraft'];
    if (rawDraft is Map<String, dynamic>) {
      draft = PersonalizedChallengeDraft.fromJson(rawDraft).validated();
    } else if (rawDraft is Map) {
      draft = PersonalizedChallengeDraft.fromJson(
        Map<String, dynamic>.from(rawDraft),
      ).validated();
    }

    return CoachResponse(
      message: json['message']?.toString() ?? '',
      insightCards: cards,
      challengeDraft: draft,
      fromFallback: json['fromFallback'] == true,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        message,
        insightCards,
        challengeDraft,
        fromFallback,
      ];
}
