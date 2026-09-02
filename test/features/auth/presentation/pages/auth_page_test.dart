import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_auth_page.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit authCubit;

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
      // Pin the locale so the expectations below stay deterministic; the
      // strings themselves are read back through `AppLocalizations`.
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
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

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(RostokAuthPage)));

  testWidgets('renders sign-in mode', (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final AppLocalizations l10n = l10nOf(tester);
    expect(find.text(l10n.authBrandName), findsOneWidget);
    expect(find.text(l10n.authSignInHeadline), findsOneWidget);
    expect(find.text(l10n.authModeSignIn), findsOneWidget);
    expect(find.text(l10n.authModeRegister), findsOneWidget);
    expect(find.text(l10n.authSignInButton), findsOneWidget);
  });

  testWidgets('toggle switches to register mode', (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final AppLocalizations l10n = l10nOf(tester);
    await tester.tap(find.text(l10n.authModeRegister));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authRegisterHeadline), findsOneWidget);
    expect(find.text(l10n.authCreateAccountButton), findsOneWidget);
  });

  testWidgets('invalid submit shows errors and does not call the cubit',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final AppLocalizations l10n = l10nOf(tester);
    await tester.tap(find.text(l10n.authSignInButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authEmailError), findsOneWidget);
    // 8 is the minimum password length enforced by RostokAuthPage.
    expect(find.text(l10n.authPasswordError(8)), findsOneWidget);
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

    await tester.tap(find.text(l10nOf(tester).authSignInButton));
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

    final Finder submit = find.text(l10nOf(tester).authCreateAccountButton);
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
