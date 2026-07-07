abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String categoryDetails = '/category/:categoryId';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String progress = '/progress';
  static const String premium = '/premium';
  static const String analytics = '/analytics';
  static const String education = '/education/:categoryId';

  // Росток (Sprout) redesign — new screens built alongside the current UI.
  static const String rostok = '/rostok';
  static const String rostokAuth = '/rostok/auth';
  static const String rostokHome = '/rostok/home';
  static const String rostokProfile = '/rostok/profile';
  static const String rostokChallenges = '/rostok/challenges';
  static const String rostokReward = '/rostok/reward';
}
