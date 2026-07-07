import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_challenges_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_home_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_profile_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_reward_page.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockDailyTrackerCubit extends MockCubit<DailyTrackerState>
    implements DailyTrackerCubit {}

class _MockGamificationCubit extends MockCubit<GamificationState>
    implements GamificationCubit {}

class _MockUserProfileCubit extends MockCubit<UserProfileState>
    implements UserProfileCubit {}

class _MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

const UserProfile _profile = UserProfile(
  id: 'u1',
  email: 'anya@example.com',
  displayName: 'Аня',
  onboardingCompleted: true,
);

GamificationOverview _overview() {
  final DateTime now = DateTime.parse('2026-04-09T00:00:00Z');
  return GamificationOverview(
    profile: UserGameProfile(
      userId: 'u1',
      totalXp: 3800,
      currentLevel: GameLevelTable.levels[3],
      currentStreak: 5,
      longestStreak: 9,
      activityStreak: 5,
      completedDates: const <String>['2026-04-06', '2026-04-07', '2026-04-08'],
      earlyLogDates: const <String>[],
      earnedBadges: <EarnedBadge>[
        EarnedBadge(id: BadgeId.firstStep, earnedAt: now),
      ],
      totalCategoriesCompleted: 12,
    ),
    dailyChallenge: const GamificationChallenge(
      id: 'daily',
      type: ChallengeType.logServings,
      title: 'Съешь 5 овощей',
      description: 'Отметь пять порций овощей.',
      target: 5,
      progress: 3,
      xpReward: 60,
      dateKey: '2026-04-09',
    ),
    weeklyChallenge: const GamificationChallenge(
      id: 'weekly',
      type: ChallengeType.perfectDaysInWeek,
      title: '3 идеальных дня',
      description: 'Заверши три идеальных дня.',
      target: 3,
      progress: 2,
      xpReward: 120,
      dateKey: '2026-04-07',
      period: ChallengePeriod.weekly,
    ),
    categoryMastery: const <CategoryMastery>[
      CategoryMastery(
        categoryId: 'veg',
        title: 'Овощи',
        iconKey: 'veg',
        totalServings: 12,
        tier: MasteryTier.bronze,
        nextTierThreshold: 50,
      ),
    ],
    recentXpEvents: const <GamificationXpEvent>[],
  );
}

DailyLog _dailyLog() {
  final DateTime now = DateTime.parse('2026-04-09T00:00:00Z');
  const TrackerCategory beans = TrackerCategory(
    id: 'beans',
    title: 'Beans',
    description: '',
    targetCount: 3,
    displayOrder: 1,
    iconKey: 'beans',
    isActive: true,
  );
  const TrackerCategory berries = TrackerCategory(
    id: 'berries',
    title: 'Berries',
    description: '',
    targetCount: 1,
    displayOrder: 2,
    iconKey: 'berries',
    isActive: true,
  );
  return DailyLog(
    id: '2026-04-09',
    userId: 'u1',
    logDate: now,
    items: <DailyLogItem>[
      DailyLogItem(
        id: 'i1',
        category: beans,
        completedCount: 1,
        createdAt: now,
        updatedAt: now,
      ),
      DailyLogItem(
        id: 'i2',
        category: berries,
        completedCount: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    totalCompleted: 2,
    totalTarget: 4,
    completionPercentage: 50,
    isFullyCompleted: false,
  );
}

void main() {
  late _MockAuthCubit auth;
  late _MockDailyTrackerCubit daily;
  late _MockGamificationCubit gamification;
  late _MockUserProfileCubit user;
  late _MockSubscriptionCubit subscription;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    auth = _MockAuthCubit();
    daily = _MockDailyTrackerCubit();
    gamification = _MockGamificationCubit();
    user = _MockUserProfileCubit();
    subscription = _MockSubscriptionCubit();

    const AuthState authState = AuthUnauthenticated();
    final DailyTrackerState dailyState = DailyTrackerState(
      status: DailyTrackerStatus.loaded,
      log: _dailyLog(),
      summary: const CompletionSummary(
        totalCompleted: 2,
        totalTarget: 4,
        completionPercentage: 50,
        isFullyCompleted: false,
      ),
    );
    final GamificationLoaded gamificationState =
        GamificationLoaded(overview: _overview());
    const UserProfileState userState = UserProfileLoaded(_profile);
    const SubscriptionState subscriptionState = SubscriptionState.initial();

    whenListen<AuthState>(
      auth,
      Stream<AuthState>.value(authState),
      initialState: authState,
    );
    whenListen<DailyTrackerState>(
      daily,
      Stream<DailyTrackerState>.value(dailyState),
      initialState: dailyState,
    );
    when(() => daily.loadToday()).thenAnswer((_) async {});
    when(() => daily.increment(any())).thenAnswer((_) async {});
    when(() => daily.decrement(any())).thenAnswer((_) async {});
    whenListen<GamificationState>(
      gamification,
      Stream<GamificationState>.value(gamificationState),
      initialState: gamificationState,
    );
    when(() => gamification.load(isPremium: any(named: 'isPremium')))
        .thenAnswer((_) async {});
    whenListen<UserProfileState>(
      user,
      Stream<UserProfileState>.value(userState),
      initialState: userState,
    );
    when(() => user.load()).thenAnswer((_) async {});
    whenListen<SubscriptionState>(
      subscription,
      Stream<SubscriptionState>.value(subscriptionState),
      initialState: subscriptionState,
    );
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<DailyTrackerCubit>.value(value: daily),
          BlocProvider<GamificationCubit>.value(value: gamification),
          BlocProvider<UserProfileCubit>.value(value: user),
          BlocProvider<SubscriptionCubit>.value(value: subscription),
        ],
        child: child,
      ),
    );
  }

  testWidgets('Главный renders daily categories', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const RostokHomePage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Съедено сегодня'), findsOneWidget);
    expect(find.text('Beans'), findsOneWidget);
  });

  testWidgets('Профиль renders stats and achievements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const RostokProfilePage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Профиль'), findsOneWidget);
    expect(find.text('Достижения'), findsOneWidget);
    expect(find.text('Аня'), findsOneWidget);
  });

  testWidgets('Челленджи renders featured + daily', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const RostokChallengesPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Челленджи'), findsOneWidget);
    expect(find.text('Ежедневные'), findsOneWidget);
    expect(find.text('3 идеальных дня'), findsOneWidget);
  });

  testWidgets('Награда renders celebration', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const RostokRewardPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Забрать награду'), findsOneWidget);
  });

  testWidgets('Главный toggles a serving via the check button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const RostokHomePage()));
    await tester.pumpAndSettle();

    // Beans has completedCount 1 / target 3 -> not complete -> tap increments.
    // The check button is the GestureDetector inside the row's root DecoratedBox.
    final Finder beansTile = find
        .ancestor(of: find.text('Beans'), matching: find.byType(DecoratedBox))
        .first;
    final Finder check = find.descendant(
      of: beansTile,
      matching: find.byType(GestureDetector),
    );
    await tester.tap(check);
    await tester.pump();

    verify(() => daily.increment('beans')).called(1);
  });
}
