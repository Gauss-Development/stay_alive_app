import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/auth/presentation/pages/login_page.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit authCubit;

  setUp(() {
    authCubit = _MockAuthCubit();
    when(() => authCubit.state).thenReturn(const AuthInitial());
    when(() => authCubit.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async {});
    whenListen<AuthState>(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('shows validation errors for invalid form submission', (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    verifyNever(() => authCubit.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')));
  });

  testWidgets('submits trimmed email and password for valid form', (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.byType(TextFormField).at(0), '  user@example.com  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    verify(
      () => authCubit.signInWithEmail(
        email: 'user@example.com',
        password: 'password123',
      ),
    ).called(1);
  });
}
