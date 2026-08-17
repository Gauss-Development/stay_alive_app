import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';

void main() {
  testWidgets('RostokColors exposes brand mascot green', (
    WidgetTester tester,
  ) async {
    expect(RostokColors.mascot, isA<Color>());
    expect(RostokColors.mascot.toARGB32(), isNonZero);
  });
}
