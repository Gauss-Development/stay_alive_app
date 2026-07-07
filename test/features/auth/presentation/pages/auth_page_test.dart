import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_auth_page.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit authCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    authCubit = _MockAuthCubit();
    whenListen<AuthState>(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );
    when(
      () => authCubit.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => authCubit.signUpWithEmail(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  // disableAnimations stops the looping mascot animation so pumpAndSettle
  // can reach a steady state.
  Widget buildWidget([RostokAuthMode mode = RostokAuthMode.signIn]) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: BlocProvider<AuthCubit>.value(
              value: authCubit,
              child: RostokAuthPage(initialMode: mode),
            ),
          );
        },
      ),
    );
  }

  testWidgets('renders sign-in mode', (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('росток'), findsOneWidget);
    expect(find.text('С возвращением!'), findsOneWidget);
    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('toggle switches to register mode', (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();

    expect(find.text('Создай аккаунт'), findsOneWidget);
    expect(find.text('Создать аккаунт'), findsOneWidget);
  });

  testWidgets('invalid submit shows errors and does not call the cubit',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Введите корректную почту'), findsOneWidget);
    expect(find.text('Минимум 8 символов'), findsOneWidget);
    verifyNever(
      () => authCubit.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('valid sign-in submits trimmed credentials',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField).at(1), '  user@example.com  ');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.pump();

    await tester.tap(find.text('Войти'));
    await tester.pump();

    verify(
      () => authCubit.signInWithEmail(
        email: 'user@example.com',
        password: 'password123',
      ),
    ).called(1);
  });

  testWidgets('register submits name, email and password',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget(RostokAuthMode.register));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Аня');
    await tester.enterText(find.byType(TextField).at(1), 'anya@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.pump();

    final Finder submit = find.text('Создать аккаунт');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pump();

    verify(
      () => authCubit.signUpWithEmail(
        name: 'Аня',
        email: 'anya@example.com',
        password: 'password123',
      ),
    ).called(1);
  });
}
