import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/garden_sprout.dart';

void main() {
  const GardenState state = GardenState(
    stage: GardenStage.sprout,
    mood: SproutMood.happy,
    health: 0.8,
    wilting: false,
    todayGrowth: 0.5,
    levelTitle: 'Sprout',
    level: 2,
  );

  Widget app({required bool reduceMotion}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: const Scaffold(body: GardenSprout(state: state)),
      ),
    );
  }

  testWidgets('idle breathing keeps ticking while the sprout is visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(reduceMotion: false));
    // Past the mood cross-fade, so any remaining frame demand is the
    // breathing controller and nothing else.
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('reduced motion drops the ticker instead of muting it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(reduceMotion: true));
    // A repeating controller would make this time out rather than settle.
    await tester.pumpAndSettle();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a hidden TickerMode stops driving frames', (
    WidgetTester tester,
  ) async {
    // Mirrors MainShellPage: an off-screen tab must not animate.
    await tester.pumpWidget(
      const MaterialApp(
        home: TickerMode(
          enabled: false,
          child: Scaffold(body: GardenSprout(state: state)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
