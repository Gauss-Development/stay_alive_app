import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_overview_builder.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';

void main() {
  const TrackerCategory greens = TrackerCategory(
    id: 'greens',
    title: 'Greens',
    description: 'Greens',
    targetCount: 1,
    displayOrder: 1,
    iconKey: 'greens',
    isActive: true,
  );

  test('premium AI draft replaces daily challenge and awards XP once', () {
    const GamificationOverviewBuilder builder = GamificationOverviewBuilder();
    final DateTime day = DateTime(2026, 8, 5);
    final DailyLog log = DailyLog(
      id: '1',
      userId: 'u1',
      logDate: day,
      items: <DailyLogItem>[
        DailyLogItem(
          id: 'i1',
          category: greens,
          completedCount: 1,
          createdAt: day,
          updatedAt: day,
        ),
      ],
      totalCompleted: 1,
      totalTarget: 1,
      completionPercentage: 100,
      isFullyCompleted: false,
    );

    const PersonalizedChallengeDraft draft = PersonalizedChallengeDraft(
      title: 'Focus: greens',
      description: 'Close greens',
      target: 1,
      xpReward: 45,
      categoryId: 'greens',
      challengeType: 'completeCategory',
    );

    final overview = builder.build(
      userId: 'u1',
      logs: <DailyLog>[log],
      persistedEvents: const <GamificationXpEvent>[],
      referenceDate: day,
      isPremium: true,
      personalizedDailyDraft: draft,
    );

    expect(overview.dailyChallenge.id, 'ai_daily_2026-08-05');
    expect(overview.dailyChallenge.isCompleted, isTrue);
    expect(overview.dailyChallenge.type, ChallengeType.completeCategory);
    expect(overview.profile.totalXp, greaterThanOrEqualTo(45));
  });
}
