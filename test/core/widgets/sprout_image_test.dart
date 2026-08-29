import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/core/widgets/sprout_image.dart';

void main() {
  testWidgets('every sprout mood asset exists and decodes', (
    WidgetTester tester,
  ) async {
    for (final SproutMood mood in SproutMood.values) {
      await tester.pumpWidget(
        MaterialApp(home: SproutImage(mood: mood, size: 96)),
      );
      // Let the cross-fade from the previous mood finish so only one
      // Image remains in the AnimatedSwitcher.
      await tester.pump(const Duration(milliseconds: 350));

      final Image image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, mood.assetPath);

      // Decode the real bundled asset — fails loudly on a missing or
      // corrupt PNG rather than silently rendering an error box.
      await tester.runAsync(
        () => precacheImage(
          image.image,
          tester.element(find.byType(SproutImage)),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: mood.name);
    }
  });

  testWidgets('mood change cross-fades to the new asset', (
    WidgetTester tester,
  ) async {
    Widget build(SproutMood mood) =>
        MaterialApp(home: SproutImage(mood: mood, size: 96));

    await tester.pumpWidget(build(SproutMood.waiting));
    await tester.pumpWidget(build(SproutMood.celebrating));
    // Mid-transition both images live inside the AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(Image), findsNWidgets(2));

    await tester.pump(const Duration(milliseconds: 200));
    final Image image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      SproutMood.celebrating.assetPath,
    );
  });
}
