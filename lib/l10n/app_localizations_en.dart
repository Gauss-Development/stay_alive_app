// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sprout';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Stats';

  @override
  String get navProfile => 'Profile';

  @override
  String get coachTitle => 'AI coach';

  @override
  String get coachPaywallTitle => 'Coach chat is part of Stay Alive Pro';

  @override
  String get coachPaywallDescription =>
      'Personal tips, weekly reviews and garden quests. It\'s Daily Dozen motivation, not medical advice.';

  @override
  String get coachPaywallCta => 'Get Premium';

  @override
  String get coachChatDisclaimer =>
      'The coach helps you keep the Daily Dozen habit. It doesn\'t replace your doctor.';

  @override
  String get coachChatEmptyHint =>
      'Ask what to add today, or how to keep your streak going.';

  @override
  String get coachChatInputHint => 'Message the coach…';

  @override
  String get coachWeeklyTitle => 'Weekly review';

  @override
  String get coachWeeklyRefresh => 'Refresh';

  @override
  String get coachWeeklyPremiumCta => 'Insights in Stay Alive Pro';

  @override
  String get coachWeeklyRequestCta => 'Get your weekly review';

  @override
  String get coachInsightUntitled => 'Insight';

  @override
  String get coachNudgeTitle => 'Sprout coach';

  @override
  String get coachNudgeOpenChat => 'Open chat';

  @override
  String get coachNudgeLimitReached =>
      'You\'ve used up today\'s tips. Open the Pro chat.';

  @override
  String coachFallbackNudgeWilting(int streak) {
    return 'Your sprout is drooping a little — even one serving today keeps the streak alive (currently $streak).';
  }

  @override
  String coachFallbackNudgeNextStep(
    int completed,
    int target,
    String category,
  ) {
    return 'Great progress: $completed/$target. Next up — $category.';
  }

  @override
  String get coachFallbackNudgeAllDone =>
      'Every category is done for today — your sprout is grateful!';

  @override
  String coachFallbackChatIntro(int streak) {
    return 'I\'m the Sprout coach. Ask what to add today, or how to keep your streak going (currently $streak). I don\'t diagnose anything — I only cheer you on through the Daily Dozen.';
  }

  @override
  String coachFallbackChatGaps(String categories, String levelTitle) {
    return 'Your log is still missing: $categories. Pick one category and tick off a serving — small steps build up your $levelTitle level.';
  }

  @override
  String get coachFallbackChatAllDone =>
      'Everything is done today. Tomorrow, aim for an early log before 9:00 — it earns bonus points and keeps your sprout happy.';

  @override
  String get coachFallbackWeeklyMessage => 'Your weekly review is ready.';

  @override
  String get coachFallbackWeeklyStreakTitle => 'Streak';

  @override
  String coachFallbackWeeklyStreakBody(
    int streak,
    int activityStreak,
    String levelTitle,
  ) {
    return 'Perfect streak: $streak · active days: $activityStreak. Level $levelTitle.';
  }

  @override
  String get coachFallbackWeeklyStreakKeepRhythm => 'keep the rhythm';

  @override
  String get coachFallbackWeeklyStreakComeBack => 'come back today';

  @override
  String get coachFallbackWeeklyGapsTitle => 'Gaps';

  @override
  String get coachFallbackWeeklyGapsNone =>
      'Today\'s categories are all closed — a great benchmark for the week.';

  @override
  String coachFallbackWeeklyGapsList(String categories) {
    return 'Most often left open: $categories.';
  }

  @override
  String get coachFallbackWeeklyAdviceTitle => 'Coach\'s tip';

  @override
  String get coachFallbackWeeklyAdviceBody =>
      'Plan 1–2 “anchors” (greens + beans) for the first half of the day.';

  @override
  String get coachFallbackChallengeMessage =>
      'Your personal garden quest for today.';

  @override
  String coachFallbackChallengeTitle(String category) {
    return 'Focus: $category';
  }

  @override
  String coachFallbackChallengeDescription(String category) {
    return 'Close the $category category today — your sprout will grow stronger.';
  }

  @override
  String coachFallbackEducationTip(String category) {
    return 'The “$category” category is part of the Daily Dozen. Add servings gradually, with no strict diet rules. It\'s a habit, not a treatment.';
  }

  @override
  String get educationTitle => 'Good to know';

  @override
  String get educationLoading => 'Preparing your tip…';

  @override
  String get educationEmptyTitle => 'Something good is coming here';

  @override
  String educationEmptyMessage(String category) {
    return 'Material about the “$category” category is on its way.';
  }

  @override
  String get educationDisclaimer =>
      'The coach\'s tip is Daily Dozen motivation, not medical advice.';

  @override
  String get progressLoading => 'Loading your quests...';

  @override
  String get progressTitle => 'Challenges';

  @override
  String get progressSectionDaily => 'Daily';

  @override
  String progressPremiumActive(num multiplier) {
    return 'Premium active · ${multiplier}x points';
  }

  @override
  String get progressStreakPerfect => 'Perfect streak';

  @override
  String get progressStreakActive => 'Active streak';

  @override
  String get progressStreakRecord => 'Personal best';

  @override
  String get progressPerfectDays => 'Perfect days';

  @override
  String get progressStreakFreezes => 'Freezes';

  @override
  String get progressSectionAchievements => 'Achievements';

  @override
  String get progressSectionRecentBadges => 'Recent rewards';

  @override
  String get progressSectionCategories => 'Category progress';

  @override
  String get progressSectionXpHistory => 'Points history';

  @override
  String get progressGenerateQuest => 'Generate a garden quest';

  @override
  String get progressSproutWaiting => 'Your sprout is waiting for you today';

  @override
  String get progressXpHistoryEmpty => 'Your points history will show up here.';

  @override
  String progressLevelWithTitle(int level, String title) {
    return 'Level $level · $title';
  }

  @override
  String get challengeBadgeDailyPremium => 'Quest · Premium';

  @override
  String get challengeBadgeDaily => 'Quest of the day';

  @override
  String get challengeLockedDaily =>
      'Unlock Premium to earn bonus points for this quest.';

  @override
  String get challengeDone => 'Done!';

  @override
  String get challengeBadgeWeekly => 'CHALLENGE OF THE WEEK';

  @override
  String get challengeLockedWeekly =>
      'Unlock Premium to join the weekly challenge.';

  @override
  String get challengeCompleted => 'Completed!';

  @override
  String challengeProgressOf(int progress, int target) {
    return '$progress of $target';
  }

  @override
  String challengeXpReward(int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp points',
      one: '$xp point',
    );
    return '+$_temp0';
  }

  @override
  String challengeDailyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp points',
      one: '$xp point',
    );
    return 'Daily quest complete: $title (+$_temp0)';
  }

  @override
  String challengeWeeklyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp points',
      one: '$xp point',
    );
    return 'Weekly challenge complete: $title (+$_temp0)';
  }

  @override
  String get masteryEmpty => 'Log what you eat — and level up your categories.';

  @override
  String masteryServingsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings logged',
      one: '$count serving logged',
    );
    return '$_temp0';
  }

  @override
  String masteryServingsToNextTier(int current, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target servings',
      one: '$target serving',
    );
    return '$current/$_temp0 to the next tier';
  }

  @override
  String get masteryTierBronze => 'Bronze';

  @override
  String get masteryTierSilver => 'Silver';

  @override
  String get masteryTierGold => 'Gold';

  @override
  String get masteryTierPlatinum => 'Platinum';

  @override
  String get levelUpBadge => 'NEW LEVEL';

  @override
  String levelUpLevel(int level) {
    return 'Level $level';
  }

  @override
  String get levelUpSubtitle => 'Your sprout just got stronger';

  @override
  String get levelUpContinue => 'Continue';

  @override
  String badgeUnlockedToast(String emoji, String name) {
    return '$emoji New reward: $name';
  }

  @override
  String get badgeLocked => 'Locked';

  @override
  String get badgeEmpty => 'No rewards yet — they\'re all still ahead of you!';

  @override
  String get historyLoading => 'Counting up your progress...';

  @override
  String historyLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last $count days',
      one: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String get historySubtitle => 'Watch your healthy habit grow.';

  @override
  String get historyPaywallTitle => 'Full stats come with Premium';

  @override
  String get historyPaywallBody =>
      'Logging healthy foods is free. With Premium you’ll see trends, streaks, serving charts and a whole month of progress.';

  @override
  String get historyPaywallCta => 'See Premium';

  @override
  String get historyPaywallRestore => 'I’m already subscribed — refresh';

  @override
  String get historyHeatmapTitle => 'Day map';

  @override
  String get historyLegendGoalMet => 'Goal met';

  @override
  String get historyLegendPartial => 'Partial';

  @override
  String get historyLegendNoEntry => 'No entry';

  @override
  String historyHeatmapTooltip(
    String date,
    int done,
    int total,
    String percent,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'servings',
      one: 'serving',
    );
    return '$date: $done/$total $_temp0 ($percent%)';
  }

  @override
  String get historyAveragePeriod => 'Period average';

  @override
  String historyFullDays(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'full days',
      one: 'full day',
    );
    return '$done/$total $_temp0';
  }

  @override
  String get historyCurrentStreak => 'Current streak';

  @override
  String historyDaysInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days in a row',
      one: 'day in a row',
    );
    return '$_temp0';
  }

  @override
  String get historyBestRecord => 'Record';

  @override
  String get historyBestStreakSubtitle => 'best streak';

  @override
  String get historyWeeklyAverage => 'weekly average';

  @override
  String get profileChallengesTitle => 'Challenges & rewards';

  @override
  String get profileChallengesSubtitle => 'Quests, streaks and every badge';

  @override
  String profileLevelCaption(int level, String title) {
    return 'Level $level · $title 🌱';
  }

  @override
  String get profileStatTotalPoints => 'total points';

  @override
  String profileStatStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 day streak',
      one: '🔥 day streak',
    );
    return '$_temp0';
  }

  @override
  String get profileStatRecord => '🏆 record';

  @override
  String get profileMaxLevel => 'Top level reached';

  @override
  String profileNextLevel(int level, String title) {
    return 'To level $level · $title';
  }

  @override
  String get profileAchievements => 'Achievements';

  @override
  String profileAchievementsCount(int unlocked, int total) {
    return '$unlocked of $total';
  }

  @override
  String get profileWeeklyActivity => 'Your week';

  @override
  String get profileWeekdayMon => 'Mon';

  @override
  String get profileWeekdayTue => 'Tue';

  @override
  String get profileWeekdayWed => 'Wed';

  @override
  String get profileWeekdayThu => 'Thu';

  @override
  String get profileWeekdayFri => 'Fri';

  @override
  String get profileWeekdaySat => 'Sat';

  @override
  String get profileWeekdaySun => 'Sun';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsOfService => 'Terms of Use';

  @override
  String get profileLinkOpenFailed => 'Couldn’t open that link';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'This permanently erases your profile, daily entries, history, progress and subscription data. There’s no undo.\n\nDeleting your account does not cancel an active App Store / Play Store subscription — manage that in your store’s subscription settings.';

  @override
  String profileDeleteAccountFailed(String message) {
    return 'Couldn’t delete your account: $message';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonErrorTitle => 'Couldn’t load that';

  @override
  String get commonErrorMessage =>
      'Check your connection and give it another go';

  @override
  String get commonRetry => 'Try again';

  @override
  String get homeLoading => 'Getting your day ready...';

  @override
  String get homeAiCoach => 'AI coach';

  @override
  String get homeEatenToday => 'Eaten today';

  @override
  String get homeEmptyTitle => 'Nothing here yet';

  @override
  String get homeEmptyMessage =>
      'Add your first healthy food and start earning points';

  @override
  String get homeResetDay => 'Reset day';

  @override
  String get homeFilterAll => 'All';

  @override
  String get homeFilterRemaining => 'Left';

  @override
  String get homeFilterDone => 'Done';

  @override
  String get homeGreeting => 'Hi there! 🌱';

  @override
  String homeGreetingNamed(String name) {
    return 'Hi, $name 🌱';
  }

  @override
  String get homeGreetingQuestion => 'What good stuff are we eating?';

  @override
  String get homeTileDone => 'Done · +points';

  @override
  String get homeTileTapToMark => 'Tap to check it off';

  @override
  String homeRemoveServingSemantics(String category) {
    return 'Remove a serving: $category';
  }

  @override
  String homeCategoryCompletedSemantics(String category) {
    return '$category — done';
  }

  @override
  String homeAddServingSemantics(String category, int completed, int total) {
    return 'Add a serving: $category ($completed of $total)';
  }

  @override
  String homeProgressOfGoal(int goal) {
    return 'of $goal';
  }

  @override
  String homeLevelBadge(int level, String title) {
    return 'Level $level · $title';
  }

  @override
  String homeRemainingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings left to hit your daily goal',
      one: '$count serving left to hit your daily goal',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalReached => 'Daily goal complete!';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count days in a row',
      one: '🔥 $count day in a row',
    );
    return '$_temp0';
  }

  @override
  String get authBrandName => 'sprout';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authRegisterHeadline => 'Create your account';

  @override
  String get authSignInHeadline => 'Welcome back!';

  @override
  String get authRegisterSubtitle => 'A couple of steps and the game begins.';

  @override
  String get authSignInSubtitle => 'Keep growing your sprout.';

  @override
  String get authModeSignIn => 'Sign in';

  @override
  String get authModeRegister => 'Sign up';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authNameError => 'Enter your name';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailError => 'Enter a valid email address';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String authPasswordError(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'At least $count characters',
      one: 'At least $count character',
    );
    return '$_temp0';
  }

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authDividerOr => 'or';

  @override
  String get onboardingTitle => 'Eat well —\nearn points';

  @override
  String get onboardingSubtitle =>
      'Check off healthy foods, finish quests and grow your level.';

  @override
  String get onboardingStartButton => 'Start the game';

  @override
  String get splashLoading => 'Growing your sprout...';

  @override
  String get splashStartupError => 'We could not start the app.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSystemDefault => 'System default';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out?';

  @override
  String get settingsSignOutConfirmBody =>
      'Your progress stays on the server — just sign back in.';

  @override
  String get settingsSubscriptionActive => 'Stay Alive Pro is active';

  @override
  String get settingsSubscriptionFree => 'Free plan';

  @override
  String settingsSubscriptionExpires(String date) {
    return 'Active until $date';
  }

  @override
  String get settingsManageSubscription => 'Manage subscription';

  @override
  String get settingsRestorePurchases => 'Restore purchases';

  @override
  String get settingsManageUnavailable => 'Available once you subscribe';
}
