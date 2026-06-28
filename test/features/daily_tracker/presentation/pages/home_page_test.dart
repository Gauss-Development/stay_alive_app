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
import 'package:stay_alive/features/daily_tracker/presentation/pages/home_page.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class _MockDailyTrackerCubit extends MockCubit<DailyTrackerState>
    implements DailyTrackerCubit {}

class _MockGamificationCubit extends MockCubit<GamificationState>
    implements GamificationCubit {}

class _FakeHomeWidgetGateway extends Fake implements HomeWidgetGateway {}

class _FakeDailyGoalWidgetService extends DailyGoalWidgetService {
  _FakeDailyGoalWidgetService()
      : super(
          envConfig: const EnvConfig(
            appFlavor: AppFlavor.development,
            appwriteEndpoint: '',
            appwriteProjectId: '',
            appwriteProjectName: '',
            appwriteDatabaseId: '',
            usersCollectionId: '',
            categoryDefinitionsCollectionId: '',
            dailyLogsCollectionId: '',
            dailyLogItemsCollectionId: '',
            subscriptionsCollectionId: '',
            analyticsEventsCollectionId: '',
            educationalContentCollectionId: '',
            gamificationProfilesCollectionId: '',
            gamificationEventsCollectionId: '',
            widgetAppGroupId: '',
            revenueCatAndroidApiKey: '',
            revenueCatIosApiKey: '',
            revenueCatEntitlementId: 'premium',
            revenueCatOfferingId: 'default',
            avatarsBucketId: '',
            userUploadsBucketId: '',
            contentAssetsBucketId: '',
            allowSelfSigned: false,
            revenueCatApiKeyIos: '',
            revenueCatApiKeyAndroid: '',
            sentryDsn: '',
            sentryEnvironment: 'test',
          ),
          gateway: _FakeHomeWidgetGateway(),
        );

  @override
  Future<void> updateDailyGoal({
    required DailyLog log,
    GamificationProgress? progress,
  }) async {}
}

void main() {
  late _MockDailyTrackerCubit cubit;
  late _MockGamificationCubit gamificationCubit;
  late _FakeDailyGoalWidgetService dailyGoalWidgetService;
  late DailyTrackerState loadedState;

  setUp(() {
    cubit = _MockDailyTrackerCubit();
    gamificationCubit = _MockGamificationCubit();
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

    when(() => cubit.state).thenReturn(loadedState);
    when(
      () => cubit.stream,
    ).thenAnswer((_) => Stream<DailyTrackerState>.value(loadedState));
    when(() => cubit.loadToday()).thenAnswer((_) async {});
    when(() => cubit.increment(any())).thenAnswer((_) async {});
    when(() => cubit.decrement(any())).thenAnswer((_) async {});
    when(() => cubit.resetToday()).thenAnswer((_) async {});
    when(() => gamificationCubit.state).thenReturn(
      const GamificationLoaded(
        GamificationProgress(
          userId: 'user_1',
          xp: 35,
          level: 1,
          currentLevelXp: 0,
          nextLevelXp: 100,
          currentStreak: 1,
          bestStreak: 1,
          completedDays: 0,
          lastCompletedDate: null,
          badges: <String>['first_log'],
        ),
      ),
    );
    when(() => gamificationCubit.stream).thenAnswer(
      (_) => const Stream<GamificationState>.empty(),
    );
    when(() => gamificationCubit.refresh()).thenAnswer((_) async {});
  });

  Widget buildWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<DailyTrackerCubit>.value(value: cubit),
          BlocProvider<GamificationCubit>.value(value: gamificationCubit),
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

    expect(find.text('What did you eat today?'), findsOneWidget);
    expect(find.text('Beans / Legumes'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Add Beans / Legumes serving (1 of 3)'),
      findsOneWidget,
    );
  });

  testWidgets('calls increment when add icon is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    final Finder incrementButton =
        find.bySemanticsLabel('Add Beans / Legumes serving (1 of 3)');
    expect(incrementButton, findsOneWidget);
    await tester.scrollUntilVisible(
      incrementButton,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(incrementButton);
    await tester.pump();

    verify(() => cubit.increment('beans')).called(1);
  });
}
