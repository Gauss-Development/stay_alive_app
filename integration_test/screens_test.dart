import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stay_alive/bootstrap.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Walks the app and captures one screenshot per screen.
///
/// Run against a booted simulator with the local Supabase stack up:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screens_test.dart -d `sim-id` --flavor dev
///
/// `pumpAndSettle` is never used: the garden sprout breathes forever, so
/// settling would time out. Everything waits on real wall-clock frames.
/// Seeded QA account on the local Supabase stack (20 days of tracker data,
/// including a 10-day perfect streak). Created by `tool/seed_qa_account.sh`.
const String qaEmail = 'qa@stayalive.test';
const String qaPassword = 'qa-password-123';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> hold(WidgetTester tester, {int ms = 1500}) async {
    final DateTime end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    await hold(tester, ms: 700);
    await binding.takeScreenshot(name);
  }

  /// Strings as the running app renders them, so the walk survives whatever
  /// locale the simulator is set to.
  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(Scaffold).first));

  /// The (empty) text field showing [hint] as its placeholder.
  Finder fieldWithHint(String hint) => find.ancestor(
        of: find.text(hint),
        matching: find.byType(TextField),
      );

  /// Scrolls [finder] into view before tapping it — a blind `tap` silently
  /// misses anything covered by the keyboard or below the fold.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await hold(tester, ms: 400);
    await tester.tap(finder);
  }

  /// A context below the router, so `GoRouter.of` resolves.
  BuildContext routerContext(WidgetTester tester) =>
      tester.element(find.byType(Scaffold).first);

  Future<void> goTo(WidgetTester tester, String location, String name) async {
    try {
      GoRouter.of(routerContext(tester)).go(location);
      await hold(tester, ms: 2500);
      await shoot(tester, name);
    } catch (error) {
      debugPrint('screenshot $name failed: $error');
    }
  }

  /// Never let one unreachable screen abort the whole walk — without the
  /// local Supabase stack everything past sign-up fails, and the screens that
  /// *are* reachable should still be captured.
  Future<void> step(String name, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('step $name failed: $error');
    }
  }

  testWidgets('capture every screen', (WidgetTester tester) async {
    await bootstrap(AppFlavor.development);

    await tester.pump();
    await shoot(tester, '01_splash');

    // Splash resolves the session, then lands on /login.
    await hold(tester, ms: 3500);
    await shoot(tester, '02_login');

    await step('sign_up', () async {
      await tapVisible(tester, find.text(l10n(tester).authModeRegister));
      await hold(tester, ms: 1200);
      await shoot(tester, '03_sign_up');
      // Back to the sign-in tab: the seeded QA account already exists, and
      // logging into it yields populated screens instead of empty states.
      await tapVisible(tester, find.text(l10n(tester).authModeSignIn));
      await hold(tester, ms: 1000);
    });

    await step('login', () async {
      // Positional indices are unsafe here: switching back from the register
      // tab keeps the collapsing name field mounted for a few frames, which
      // shifts every index by one. Address the fields by their hint instead.
      await hold(tester, ms: 1500);
      await tester.enterText(fieldWithHint(l10n(tester).authEmailLabel), qaEmail);
      await tester.enterText(fieldWithHint(l10n(tester).authPasswordLabel), qaPassword);
      await hold(tester, ms: 400);

      // The on-screen keyboard covers the submit button, so a blind tap
      // misses it. Drop focus, then scroll the button into view first.
      FocusManager.instance.primaryFocus?.unfocus();
      await hold(tester, ms: 800);
      // In several locales the tab and the submit button share a label
      // (English: both are "Sign in"), so target the last match — the button
      // always sits below the mode switcher.
      await tapVisible(tester, find.text(l10n(tester).authSignInButton).last);

      await hold(tester, ms: 7000);
      await shoot(tester, '05_home');
    });

    await step('history', () async {
      await tapVisible(tester, find.text(l10n(tester).navStats));
      await hold(tester, ms: 3500);
      await shoot(tester, '06_history');
    });

    await step('profile', () async {
      await tapVisible(tester, find.text(l10n(tester).navProfile));
      await hold(tester, ms: 3500);
      await shoot(tester, '07_profile');

      // The settings menu lives below the fold. Target the profile's own
      // scrollable via a widget known to sit inside it — `byType(Scrollable)`
      // also matches the bottom navigation bar, which never scrolls.
      final Finder profileList = find
          .ancestor(
            of: find.text(l10n(tester).profileAchievements),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.dragUntilVisible(
        find.text(l10n(tester).settingsTitle),
        profileList,
        const Offset(0, -250),
      );
      await hold(tester, ms: 900);
      await shoot(tester, '07b_settings');
    });

    // Routes without a bottom-nav entry.
    // No '/premium' step: the paywall is now RevenueCat-hosted and opens as a
    // native modal, not as an app route.
    await goTo(tester, '/progress', '08_progress');
    await goTo(tester, '/coach', '10_coach');
    await goTo(tester, '/education/greens', '11_education');
  });
}
