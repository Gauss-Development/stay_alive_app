import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/analytics/presentation/pages/analytics_page.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/auth/presentation/pages/login_page.dart';
import 'package:stay_alive/features/auth/presentation/pages/onboarding_page.dart';
import 'package:stay_alive/features/auth/presentation/pages/sign_up_page.dart';
import 'package:stay_alive/features/auth/presentation/pages/splash_page.dart';
import 'package:stay_alive/features/categories/presentation/pages/categories_page.dart';
import 'package:stay_alive/features/daily_tracker/presentation/pages/home_page.dart';
import 'package:stay_alive/features/education/presentation/pages/education_page.dart';
import 'package:stay_alive/features/history/presentation/pages/history_page.dart';
import 'package:stay_alive/features/subscription/presentation/pages/premium_page.dart';
import 'package:stay_alive/features/user/presentation/pages/profile_page.dart';

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
      final bool isAuthenticated = authState is AuthAuthenticated;
      final bool requiresOnboarding =
          authState is AuthAuthenticated && !authState.user.onboardingCompleted;

      final bool isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signUp;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isAuthRoute) {
        return requiresOnboarding ? AppRoutes.onboarding : AppRoutes.home;
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
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (BuildContext context, GoRouterState state) =>
            const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (BuildContext context, GoRouterState state) =>
            const PremiumPage(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (BuildContext context, GoRouterState state) =>
            const AnalyticsPage(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (BuildContext context, GoRouterState state) =>
            const CategoriesPage(),
      ),
      GoRoute(
        path: AppRoutes.education,
        builder: (BuildContext context, GoRouterState state) {
          final String? categoryId = state.pathParameters['categoryId'];
          return EducationPage(categoryId: categoryId ?? '');
        },
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
