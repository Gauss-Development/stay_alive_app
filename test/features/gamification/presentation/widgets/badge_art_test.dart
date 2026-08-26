import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_art.dart';

void main() {
  testWidgets('every badge has a bundled asset that decodes', (
    WidgetTester tester,
  ) async {
    for (final BadgeId id in BadgeId.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: BadgeArt(id: id, fallbackEmoji: '❓', size: 44),
        ),
      );

      final Image image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, id.assetPath);

      // Decode the real bundled PNG — a missing/misnamed file fails here
      // instead of silently falling back to the emoji at runtime.
      await tester.runAsync(
        () => precacheImage(image.image, tester.element(find.byType(Image))),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: id.name);
    }
  });

  testWidgets('locked badge is greyed out, not hidden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BadgeArt(
          id: BadgeId.perfectDay,
          fallbackEmoji: '⭐',
          unlocked: false,
        ),
      ),
    );

    expect(find.byType(ColorFiltered), findsOneWidget);
    expect(
      tester.widget<Opacity>(find.byType(Opacity)).opacity,
      closeTo(0.4, 0.001),
    );
    expect(find.byType(Image), findsOneWidget);
  });
}
