import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/daily_tracker/presentation/pages/home_page.dart';

class _MockDailyTrackerCubit extends MockCubit<DailyTrackerState>
    implements DailyTrackerCubit {}

void main() {
  late _MockDailyTrackerCubit cubit;
  late DailyTrackerState loadedState;

  setUp(() {
    cubit = _MockDailyTrackerCubit();
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
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<DailyTrackerCubit>.value(
        value: cubit,
        child: const HomePage(),
      ),
    );
  }

  testWidgets('renders checklist items when tracker is loaded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.text('Today\'s Checklist'), findsOneWidget);
    expect(find.text('Beans / Legumes'), findsOneWidget);
    expect(find.text('1/3 completed'), findsNWidgets(2));
  });

  testWidgets('calls increment when add icon is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    final Finder incrementButton = find.byIcon(Icons.add_circle_outline);
    expect(incrementButton, findsOneWidget);
    await tester.tap(incrementButton);
    await tester.pump();

    verify(() => cubit.increment('beans')).called(1);
  });
}
