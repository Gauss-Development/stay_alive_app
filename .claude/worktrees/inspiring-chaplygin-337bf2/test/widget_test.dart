import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:stay_alive/features/auth/presentation/widgets/auth_submit_button.dart';

void main() {
  testWidgets('AuthSubmitButton shows loading indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthSubmitButton(
            label: 'Continue',
            isLoading: true,
            onPressed: null,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
