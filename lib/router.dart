import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/features/analytics/presentation/pages/analytics_page.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/auth/presentation/pages/onboarding_page.dart';
import 'package:stay_alive/features/auth/presentation/pages/splash_page.dart';
import 'package:stay_alive/features/categories/presentation/pages/categories_page.dart';
import 'package:stay_alive/features/education/presentation/pages/education_page.dart';
import 'package:stay_alive/features/gamification/presentation/pages/progress_page.dart';
import 'package:stay_alive/features/subscription/presentation/pages/premium_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_auth_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_challenges_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_gallery_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_home_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_profile_page.dart';
import 'package:stay_alive/features/rostok/presentation/pages/rostok_reward_page.dart';
import 'package:stay_alive/shared/widgets/main_shell_page.dart';

/// Soft default transition: fade + slight upward slide.
CustomTransitionPage<void> _fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: AppCurves.soft,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
  );
}

/// Expressive transition for celebration screens: fade + subtle scale.
CustomTransitionPage<void> _rewardPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: AppCurves.standard,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          );
        },
  );
}

class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _GoRouterRefreshStream(_authCubit.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAtSplash = state.matchedLocation == AppRoutes.splash;
      if (isAtSplash) {
        return null;
      }

      final AuthState authState = _authCubit.state;
      if (authState is AuthLoading) {
        return null;
      }

      final bool isAuthenticated = authState is AuthAuthenticated;
      final bool requiresOnboarding =
          authState is AuthAuthenticated && !authState.user.onboardingCompleted;

      final bool isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signUp;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isAuthRoute) {
        return requiresOnboarding ? AppRoutes.onboarding : AppRoutes.home;
      }

      if (isAuthenticated &&
          !requiresOnboarding &&
          state.matchedLocation == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      if (isAuthenticated &&
          requiresOnboarding &&
          state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const RostokAuthPage()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(
              state,
              const RostokAuthPage(initialMode: RostokAuthMode.register),
            ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const MainShellPage(initialIndex: 0)),
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const MainShellPage(initialIndex: 1)),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const MainShellPage(initialIndex: 2)),
      ),
      GoRoute(
        path: AppRoutes.progress,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const ProgressPage()),
      ),
      GoRoute(
        path: AppRoutes.premium,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const PremiumPage()),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const AnalyticsPage()),
      ),
      GoRoute(
        path: AppRoutes.categories,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const CategoriesPage()),
      ),
      GoRoute(
        path: AppRoutes.education,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final String? categoryId = state.pathParameters['categoryId'];
          return _fadeSlidePage(
            state,
            EducationPage(categoryId: categoryId ?? ''),
          );
        },
      ),
      // Росток (Sprout) redesign — new screens alongside the current UI.
      GoRoute(
        path: AppRoutes.rostok,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const RostokGalleryPage()),
      ),
      GoRoute(
        path: AppRoutes.rostokHome,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const RostokHomePage()),
      ),
      GoRoute(
        path: AppRoutes.rostokProfile,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const RostokProfilePage()),
      ),
      GoRoute(
        path: AppRoutes.rostokChallenges,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadeSlidePage(state, const RostokChallengesPage()),
      ),
      GoRoute(
        path: AppRoutes.rostokReward,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _rewardPage(state, const RostokRewardPage()),
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((dynamic _) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit authCubit) {
  return AppRouter(authCubit).router;
}
