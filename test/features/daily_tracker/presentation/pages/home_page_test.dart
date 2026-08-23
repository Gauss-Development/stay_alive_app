import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';
import 'package:stay_alive/features/daily_tracker/presentation/pages/home_page.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

class _MockDailyTrackerCubit extends MockCubit<DailyTrackerState>
    implements DailyTrackerCubit {}

class _MockGamificationCubit extends MockCubit<GamificationState>
    implements GamificationCubit {}

class _MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

class _MockUserProfileCubit extends MockCubit<UserProfileState>
    implements UserProfileCubit {}

class _MockCoachCubit extends MockCubit<CoachState> implements CoachCubit {}

class _FakeHomeWidgetGateway extends Fake implements HomeWidgetGateway {}

class _FakeDailyGoalWidgetService extends DailyGoalWidgetService {
  _FakeDailyGoalWidgetService()
    : super(
        envConfig: const EnvConfig(
          appFlavor: AppFlavor.development,
          supabaseUrl: '',
          supabaseAnonKey: '',
          widgetAppGroupId: '',
          revenueCatAndroidApiKey: '',
          revenueCatIosApiKey: '',
          revenueCatEntitlementId: 'premium',
          revenueCatOfferingId: 'default',
          sentryDsn: '',
          sentryEnvironment: 'test',
        ),
        gateway: _FakeHomeWidgetGateway(),
      );

  @override
  Future<void> updateDailyGoal({
    required DailyLog log,
    UserGameProfile? profile,
  }) async {}
}

void main() {
  late _MockDailyTrackerCubit cubit;
  late _MockGamificationCubit gamificationCubit;
  late _MockSubscriptionCubit subscriptionCubit;
  late _MockUserProfileCubit userProfileCubit;
  late _MockCoachCubit coachCubit;
  late _FakeDailyGoalWidgetService dailyGoalWidgetService;
  late DailyTrackerState loadedState;

  setUpAll(() {
    registerFallbackValue(
      DailyLog(
        id: 'fallback',
        userId: 'user_1',
        logDate: DateTime.parse('2026-04-09T00:00:00Z'),
        items: const <DailyLogItem>[],
        totalCompleted: 0,
        totalTarget: 0,
        completionPercentage: 0,
        isFullyCompleted: false,
      ),
    );
    registerFallbackValue(
      const CoachContextPayload(
        level: 1,
        levelTitle: 'Seedling',
        streak: 0,
        activityStreak: 0,
        todayCompleted: 0,
        todayTarget: 24,
        incompleteCategories: <String>[],
        wilting: false,
      ),
    );
  });

  setUp(() {
    cubit = _MockDailyTrackerCubit();
    gamificationCubit = _MockGamificationCubit();
    subscriptionCubit = _MockSubscriptionCubit();
    userProfileCubit = _MockUserProfileCubit();
    coachCubit = _MockCoachCubit();
    dailyGoalWidgetService = _FakeDailyGoalWidgetService();
    final DateTime now = DateTime.parse('2026-04-09T00:00:00Z');
    const TrackerCategory category = TrackerCategory(
      id: 'beans',
      title: 'Beans / Legumes',
      description: 'Track bean servings',
      targetCount: 3,
      displayOrder: 1,
      iconKey: 'beans',
      isActive: true,
    );
    final DailyLog log = DailyLog(
      id: '2026-04-09',
      userId: 'user_1',
      logDate: now,
      items: <DailyLogItem>[
        DailyLogItem(
          id: 'item_1',
          category: category,
          completedCount: 1,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      totalCompleted: 1,
      totalTarget: 3,
      completionPercentage: 33.3,
      isFullyCompleted: false,
    );
    const CompletionSummary summary = CompletionSummary(
      totalCompleted: 1,
      totalTarget: 3,
      completionPercentage: 33.3,
      isFullyCompleted: false,
    );
    loadedState = DailyTrackerState(
      status: DailyTrackerStatus.loaded,
      log: log,
      summary: summary,
    );

    whenListen<DailyTrackerState>(
      cubit,
      Stream<DailyTrackerState>.value(loadedState),
      initialState: loadedState,
    );
    when(() => cubit.loadToday()).thenAnswer((_) async {});
    when(() => cubit.increment(any())).thenAnswer((_) async {});
    when(() => cubit.decrement(any())).thenAnswer((_) async {});
    when(() => cubit.resetToday()).thenAnswer((_) async {});
    final GamificationOverview gamificationOverview = GamificationOverview(
      profile: UserGameProfile(
        userId: 'user_1',
        totalXp: 35,
        currentLevel: GameLevelTable.levels.first,
        currentStreak: 1,
        longestStreak: 1,
        activityStreak: 1,
        completedDates: <String>[],
        earlyLogDates: <String>[],
        earnedBadges: <EarnedBadge>[],
        totalCategoriesCompleted: 0,
      ),
      dailyChallenge: const GamificationChallenge(
        id: 'daily_2026-04-09',
        type: ChallengeType.logServings,
        title: 'Servings Sprint',
        description: 'Log 8 servings today.',
        target: 8,
        progress: 1,
        xpReward: 35,
        dateKey: '2026-04-09',
      ),
      weeklyChallenge: const GamificationChallenge(
        id: 'weekly_2026-04-07',
        type: ChallengeType.perfectDaysInWeek,
        title: 'Weekly Perfectionist',
        description: 'Hit 3 perfect days this week.',
        target: 3,
        progress: 0,
        xpReward: 120,
        dateKey: '2026-04-07',
        period: ChallengePeriod.weekly,
      ),
      categoryMastery: const <CategoryMastery>[],
      recentXpEvents: const <GamificationXpEvent>[],
    );

    final GamificationLoaded gamificationLoaded = GamificationLoaded(
      overview: gamificationOverview,
    );

    whenListen<GamificationState>(
      gamificationCubit,
      Stream<GamificationState>.value(gamificationLoaded),
      initialState: gamificationLoaded,
    );
    whenListen<SubscriptionState>(
      subscriptionCubit,
      Stream<SubscriptionState>.value(const SubscriptionState.initial()),
      initialState: const SubscriptionState.initial(),
    );
    whenListen<UserProfileState>(
      userProfileCubit,
      Stream<UserProfileState>.value(const UserProfileInitial()),
      initialState: const UserProfileInitial(),
    );
    whenListen<CoachState>(
      coachCubit,
      Stream<CoachState>.value(const CoachInitial()),
      initialState: const CoachInitial(),
    );
    when(() => userProfileCubit.load()).thenAnswer((_) async {});
    when(
      () => coachCubit.requestNudge(
        context: any(named: 'context'),
        isPremium: any(named: 'isPremium'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => gamificationCubit.load(isPremium: any(named: 'isPremium')),
    ).thenAnswer((_) async {});
    when(
      () => gamificationCubit.refreshToday(
        todayLog: any(named: 'todayLog'),
        isPremium: any(named: 'isPremium'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => gamificationCubit.refresh(isPremium: any(named: 'isPremium')),
    ).thenAnswer((_) async {});
  });

  Widget buildWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<DailyTrackerCubit>.value(value: cubit),
          BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
          BlocProvider<GamificationCubit>.value(value: gamificationCubit),
          BlocProvider<UserProfileCubit>.value(value: userProfileCubit),
          BlocProvider<CoachCubit>.value(value: coachCubit),
        ],
        child: HomePage(dailyGoalWidgetService: dailyGoalWidgetService),
      ),
    );
  }

  testWidgets('renders checklist items when tracker is loaded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();
    await tester.pump();

    final Finder checklistHeading = find.text('Съедено сегодня');
    await tester.scrollUntilVisible(
      checklistHeading,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(checklistHeading, findsOneWidget);
    expect(find.text('Beans / Legumes'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Добавить порцию: Beans / Legumes (1 из 3)'),
      findsOneWidget,
    );
  });

  testWidgets('calls increment when add icon is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();
    await tester.pump();

    final Finder incrementButton = find.bySemanticsLabel(
      'Добавить порцию: Beans / Legumes (1 из 3)',
    );
    await tester.scrollUntilVisible(
      incrementButton,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(incrementButton, findsOneWidget);
    await tester.tap(incrementButton);
    await tester.pump();

    verify(() => cubit.increment('beans')).called(1);
  });
}
