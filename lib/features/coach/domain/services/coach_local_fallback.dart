import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';

/// Rule-based coach responses used when the Appwrite Function is unavailable.
abstract final class CoachLocalFallback {
  static CoachResponse respond({
    required CoachMode mode,
    required CoachContextPayload context,
  }) {
    return switch (mode) {
      CoachMode.nudge => _nudge(context),
      CoachMode.chat => _chat(context),
      CoachMode.weeklyInsight => _weekly(context),
      CoachMode.personalizeChallenge => _challenge(context),
      CoachMode.educationTip => _education(context),
    };
  }

  static CoachResponse _nudge(CoachContextPayload context) {
    if (context.wilting) {
      return CoachResponse(
        message:
            'Росток слегка вянет — даже одна порция сегодня поддержит серию '
            '(сейчас ${context.streak} дн.).',
        suggestedActions: context.incompleteCategories.take(2).toList(),
        fromFallback: true,
      );
    }
    if (context.incompleteCategories.isNotEmpty) {
      final String next = context.incompleteCategories.first;
      return CoachResponse(
        message:
            'Отличный прогресс: ${context.todayCompleted}/${context.todayTarget}. '
            'Следующий шаг — $next.',
        suggestedActions: <String>[next],
        fromFallback: true,
      );
    }
    return const CoachResponse(
      message: 'День закрыт по всем категориям — росток благодарен!',
      fromFallback: true,
    );
  }

  static CoachResponse _chat(CoachContextPayload context) {
    final String ask = context.userMessage?.trim() ?? '';
    if (ask.isEmpty) {
      return CoachResponse(
        message:
            'Я коуч «Ростка». Спроси, что добрать сегодня, или как удержать '
            'серию ${context.streak} дн. Я не ставлю диагнозов — только мотивацию '
            'по Daily Dozen.',
        suggestedActions: context.incompleteCategories.take(3).toList(),
        fromFallback: true,
      );
    }
    if (context.incompleteCategories.isNotEmpty) {
      return CoachResponse(
        message:
            'По твоим логам не хватает: ${context.incompleteCategories.join(', ')}. '
            'Выбери одну категорию и отметь порцию — маленькие шаги копят уровень '
            '${context.levelTitle}.',
        suggestedActions: context.incompleteCategories.take(3).toList(),
        fromFallback: true,
      );
    }
    return const CoachResponse(
      message:
          'Сегодня всё закрыто. Завтра сфокусируйся на раннем логе до 9:00 — '
          'это даёт бонусные очки и поддерживает росток.',
      fromFallback: true,
    );
  }

  static CoachResponse _weekly(CoachContextPayload context) {
    return CoachResponse(
      message: 'Недельный разбор готов.',
      insightCards: <WeeklyInsightCard>[
        WeeklyInsightCard(
          title: 'Серия',
          body:
              'Идеальная серия: ${context.streak} дн., активность: '
              '${context.activityStreak} дн. Уровень ${context.levelTitle}.',
          emphasis: context.streak > 0 ? 'держи ритм' : 'вернись сегодня',
        ),
        WeeklyInsightCard(
          title: 'Пробелы',
          body: context.incompleteCategories.isEmpty
              ? 'Категории сегодня закрыты — отличный ориентир на неделю.'
              : 'Чаще всего остаются: ${context.incompleteCategories.take(3).join(', ')}.',
        ),
        WeeklyInsightCard(
          title: 'Совет коуча',
          body:
              context.weekSummary ??
              'Планируй 1–2 «якоря» (зелень + бобы) в первой половине дня.',
        ),
      ],
      fromFallback: true,
    );
  }

  static CoachResponse _challenge(CoachContextPayload context) {
    final String focus = context.incompleteCategories.isNotEmpty
        ? context.incompleteCategories.first
        : 'greens';
    return CoachResponse(
      message: 'Персональный квест сада на сегодня.',
      challengeDraft: PersonalizedChallengeDraft(
        title: 'Focus: $focus',
        description: 'Закрой категорию $focus сегодня — росток вырастет крепче.',
        target: 1,
        xpReward: 45,
        categoryId: focus,
        challengeType: 'completeCategory',
      ).validated(),
      fromFallback: true,
    );
  }

  static CoachResponse _education(CoachContextPayload context) {
    final String id = context.categoryId ?? 'greens';
    return CoachResponse(
      message:
          'Категория «$id» — часть Daily Dozen. Добавляй порции постепенно, '
          'без жёстких диетических правил. Это привычка, не лечение.',
      suggestedActions: <String>[id],
      fromFallback: true,
    );
  }
}
