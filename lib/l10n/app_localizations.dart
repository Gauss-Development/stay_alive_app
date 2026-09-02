import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// Application name shown in the OS task switcher
  ///
  /// In ru, this message translates to:
  /// **'Росток'**
  String get appTitle;

  /// Bottom navigation label for the daily tracker tab
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// Bottom navigation label for the history tab
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get navStats;

  /// Bottom navigation label for the profile tab
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// AppBar title of the AI coach chat screen
  ///
  /// In ru, this message translates to:
  /// **'AI-коуч'**
  String get coachTitle;

  /// Headline shown to free users on the coach chat screen
  ///
  /// In ru, this message translates to:
  /// **'Чат с коучем — часть Stay Alive Pro'**
  String get coachPaywallTitle;

  /// Paywall body on the coach screen; keeps the 'not medical advice' disclaimer
  ///
  /// In ru, this message translates to:
  /// **'Персональные советы, разборы недели и квесты сада. Это мотивация по Daily Dozen, не медицинские рекомендации.'**
  String get coachPaywallDescription;

  /// Button that opens the paywall from the coach screen
  ///
  /// In ru, this message translates to:
  /// **'Открыть Premium'**
  String get coachPaywallCta;

  /// Compliance disclaimer above the coach chat; must stay in every locale
  ///
  /// In ru, this message translates to:
  /// **'Коуч помогает с привычкой Daily Dozen. Не заменяет врача.'**
  String get coachChatDisclaimer;

  /// Placeholder shown when the coach chat has no messages yet
  ///
  /// In ru, this message translates to:
  /// **'Спроси, что добрать сегодня или как удержать серию.'**
  String get coachChatEmptyHint;

  /// Hint text of the coach chat input field
  ///
  /// In ru, this message translates to:
  /// **'Напиши коучу…'**
  String get coachChatInputHint;

  /// Section title of the weekly insights block
  ///
  /// In ru, this message translates to:
  /// **'Недельный разбор'**
  String get coachWeeklyTitle;

  /// Text button that re-requests the weekly insights
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get coachWeeklyRefresh;

  /// Button shown to free users instead of weekly insights
  ///
  /// In ru, this message translates to:
  /// **'Инсайты в Stay Alive Pro'**
  String get coachWeeklyPremiumCta;

  /// Button that requests the first weekly review
  ///
  /// In ru, this message translates to:
  /// **'Получить разбор недели'**
  String get coachWeeklyRequestCta;

  /// Fallback title for a weekly insight card that arrived without one
  ///
  /// In ru, this message translates to:
  /// **'Инсайт'**
  String get coachInsightUntitled;

  /// Title of the soft coach banner shown after logging a serving
  ///
  /// In ru, this message translates to:
  /// **'Коуч Ростка'**
  String get coachNudgeTitle;

  /// Banner action that opens the coach chat
  ///
  /// In ru, this message translates to:
  /// **'Открыть чат'**
  String get coachNudgeOpenChat;

  /// Error shown when a free user runs out of daily coach nudges
  ///
  /// In ru, this message translates to:
  /// **'Дневной лимит подсказок исчерпан. Открой Pro-чат.'**
  String get coachNudgeLimitReached;

  /// Offline coach nudge when the plant is wilting
  ///
  /// In ru, this message translates to:
  /// **'Росток слегка вянет — даже одна порция сегодня поддержит серию (сейчас {streak} дн.).'**
  String coachFallbackNudgeWilting(int streak);

  /// Offline coach nudge pointing at the next unfinished category
  ///
  /// In ru, this message translates to:
  /// **'Отличный прогресс: {completed}/{target}. Следующий шаг — {category}.'**
  String coachFallbackNudgeNextStep(int completed, int target, String category);

  /// Offline coach nudge when every category is complete
  ///
  /// In ru, this message translates to:
  /// **'День закрыт по всем категориям — росток благодарен!'**
  String get coachFallbackNudgeAllDone;

  /// Offline coach reply to an empty question; keeps the 'no diagnoses' disclaimer
  ///
  /// In ru, this message translates to:
  /// **'Я коуч «Ростка». Спроси, что добрать сегодня, или как удержать серию (сейчас {streak} дн.). Я не ставлю диагнозов — только мотивацию по Daily Dozen.'**
  String coachFallbackChatIntro(int streak);

  /// Offline coach chat reply listing unfinished categories
  ///
  /// In ru, this message translates to:
  /// **'По твоим логам не хватает: {categories}. Выбери одну категорию и отметь порцию — маленькие шаги копят уровень {levelTitle}.'**
  String coachFallbackChatGaps(String categories, String levelTitle);

  /// Offline coach chat reply when nothing is left for today
  ///
  /// In ru, this message translates to:
  /// **'Сегодня всё закрыто. Завтра сфокусируйся на раннем логе до 9:00 — это даёт бонусные очки и поддерживает росток.'**
  String get coachFallbackChatAllDone;

  /// Offline coach message that accompanies the weekly insight cards
  ///
  /// In ru, this message translates to:
  /// **'Недельный разбор готов.'**
  String get coachFallbackWeeklyMessage;

  /// Title of the offline weekly insight card about streaks
  ///
  /// In ru, this message translates to:
  /// **'Серия'**
  String get coachFallbackWeeklyStreakTitle;

  /// Body of the offline weekly streak card
  ///
  /// In ru, this message translates to:
  /// **'Идеальная серия: {streak} дн., активность: {activityStreak} дн. Уровень {levelTitle}.'**
  String coachFallbackWeeklyStreakBody(
    int streak,
    int activityStreak,
    String levelTitle,
  );

  /// Emphasis line on the weekly streak card when the streak is alive
  ///
  /// In ru, this message translates to:
  /// **'держи ритм'**
  String get coachFallbackWeeklyStreakKeepRhythm;

  /// Emphasis line on the weekly streak card when the streak is broken
  ///
  /// In ru, this message translates to:
  /// **'вернись сегодня'**
  String get coachFallbackWeeklyStreakComeBack;

  /// Title of the offline weekly insight card about missing categories
  ///
  /// In ru, this message translates to:
  /// **'Пробелы'**
  String get coachFallbackWeeklyGapsTitle;

  /// Weekly gaps card body when nothing is missing
  ///
  /// In ru, this message translates to:
  /// **'Категории сегодня закрыты — отличный ориентир на неделю.'**
  String get coachFallbackWeeklyGapsNone;

  /// Weekly gaps card body listing the categories left open
  ///
  /// In ru, this message translates to:
  /// **'Чаще всего остаются: {categories}.'**
  String coachFallbackWeeklyGapsList(String categories);

  /// Title of the offline weekly insight card with the coach tip
  ///
  /// In ru, this message translates to:
  /// **'Совет коуча'**
  String get coachFallbackWeeklyAdviceTitle;

  /// Default weekly coach tip when the server sent no summary
  ///
  /// In ru, this message translates to:
  /// **'Планируй 1–2 «якоря» (зелень + бобы) в первой половине дня.'**
  String get coachFallbackWeeklyAdviceBody;

  /// Offline coach message that accompanies a personalized challenge
  ///
  /// In ru, this message translates to:
  /// **'Персональный квест сада на сегодня.'**
  String get coachFallbackChallengeMessage;

  /// Title of the offline personalized challenge
  ///
  /// In ru, this message translates to:
  /// **'Фокус: {category}'**
  String coachFallbackChallengeTitle(String category);

  /// Description of the offline personalized challenge
  ///
  /// In ru, this message translates to:
  /// **'Закрой категорию {category} сегодня — росток вырастет крепче.'**
  String coachFallbackChallengeDescription(String category);

  /// Offline education tip; keeps the 'habit, not treatment' disclaimer
  ///
  /// In ru, this message translates to:
  /// **'Категория «{category}» — часть Daily Dozen. Добавляй порции постепенно, без жёстких диетических правил. Это привычка, не лечение.'**
  String coachFallbackEducationTip(String category);

  /// AppBar title of the education screen
  ///
  /// In ru, this message translates to:
  /// **'Полезное'**
  String get educationTitle;

  /// Loading message while the education tip is fetched
  ///
  /// In ru, this message translates to:
  /// **'Готовим подсказку…'**
  String get educationLoading;

  /// Empty-state title on the education screen
  ///
  /// In ru, this message translates to:
  /// **'Скоро здесь будет интересно'**
  String get educationEmptyTitle;

  /// Empty-state body on the education screen
  ///
  /// In ru, this message translates to:
  /// **'Материалы о категории «{category}» уже готовятся.'**
  String educationEmptyMessage(String category);

  /// Compliance disclaimer at the bottom of the education screen
  ///
  /// In ru, this message translates to:
  /// **'Подсказка коуча — мотивация по Daily Dozen, не медицинский совет.'**
  String get educationDisclaimer;

  /// Loading state message on the challenges/progress screen
  ///
  /// In ru, this message translates to:
  /// **'Загружаем квесты...'**
  String get progressLoading;

  /// Title of the challenges (progress) screen app bar
  ///
  /// In ru, this message translates to:
  /// **'Челленджи'**
  String get progressTitle;

  /// Section header above the daily challenge card
  ///
  /// In ru, this message translates to:
  /// **'Ежедневные'**
  String get progressSectionDaily;

  /// Note under the XP bar telling the user their Premium XP multiplier is active
  ///
  /// In ru, this message translates to:
  /// **'Premium активен · {multiplier}x очков'**
  String progressPremiumActive(num multiplier);

  /// Stat chip label: consecutive days where every goal was met
  ///
  /// In ru, this message translates to:
  /// **'Идеальная серия'**
  String get progressStreakPerfect;

  /// Stat chip label: consecutive days with at least one logged serving
  ///
  /// In ru, this message translates to:
  /// **'Активная серия'**
  String get progressStreakActive;

  /// Stat chip label: longest streak ever reached
  ///
  /// In ru, this message translates to:
  /// **'Рекорд'**
  String get progressStreakRecord;

  /// Stat chip label: total count of fully completed days
  ///
  /// In ru, this message translates to:
  /// **'Идеальные дни'**
  String get progressPerfectDays;

  /// Stat chip label: remaining streak freezes that protect a missed day
  ///
  /// In ru, this message translates to:
  /// **'Заморозки'**
  String get progressStreakFreezes;

  /// Section header above the badge gallery grid
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get progressSectionAchievements;

  /// Section header above the list of recently earned badges
  ///
  /// In ru, this message translates to:
  /// **'Недавние награды'**
  String get progressSectionRecentBadges;

  /// Section header above the per-category mastery list
  ///
  /// In ru, this message translates to:
  /// **'Прогресс по категориям'**
  String get progressSectionCategories;

  /// Section header above the XP event timeline
  ///
  /// In ru, this message translates to:
  /// **'История очков'**
  String get progressSectionXpHistory;

  /// Premium button that asks the AI coach to create a personalized daily quest
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать квест сада'**
  String get progressGenerateQuest;

  /// Gentle, non-guilty hint under the garden sprout when nothing was logged today
  ///
  /// In ru, this message translates to:
  /// **'Росток ждёт тебя сегодня'**
  String get progressSproutWaiting;

  /// Empty state for the XP event timeline
  ///
  /// In ru, this message translates to:
  /// **'Здесь появится история твоих очков.'**
  String get progressXpHistoryEmpty;

  /// Label on the XP progress bar combining the level number and its English domain title (e.g. Sprout)
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} · {title}'**
  String progressLevelWithTitle(int level, String title);

  /// Pill on the daily challenge card when the quest is locked behind Premium
  ///
  /// In ru, this message translates to:
  /// **'Квест · Premium'**
  String get challengeBadgeDailyPremium;

  /// Pill on the daily challenge card when the quest is available
  ///
  /// In ru, this message translates to:
  /// **'Квест дня'**
  String get challengeBadgeDaily;

  /// Description shown instead of the quest text when the daily challenge is Premium-only
  ///
  /// In ru, this message translates to:
  /// **'Открой Premium, чтобы получать бонусные очки за этот квест.'**
  String get challengeLockedDaily;

  /// Short progress label on the daily challenge card once it is completed
  ///
  /// In ru, this message translates to:
  /// **'Готово!'**
  String get challengeDone;

  /// Uppercase pill on the dark weekly challenge hero card
  ///
  /// In ru, this message translates to:
  /// **'ЧЕЛЛЕНДЖ НЕДЕЛИ'**
  String get challengeBadgeWeekly;

  /// Description shown instead of the challenge text when the weekly challenge is Premium-only
  ///
  /// In ru, this message translates to:
  /// **'Открой Premium, чтобы участвовать в недельном челлендже.'**
  String get challengeLockedWeekly;

  /// Progress label on the weekly challenge hero card once it is completed
  ///
  /// In ru, this message translates to:
  /// **'Выполнено!'**
  String get challengeCompleted;

  /// Progress readout on the weekly challenge hero card, e.g. 3 of 7
  ///
  /// In ru, this message translates to:
  /// **'{progress} из {target}'**
  String challengeProgressOf(int progress, int target);

  /// XP reward shown on the weekly challenge hero card, always prefixed with a plus sign
  ///
  /// In ru, this message translates to:
  /// **'+{xp, plural, one{{xp} очко} few{{xp} очка} many{{xp} очков} other{{xp} очков}}'**
  String challengeXpReward(int xp);

  /// Snack bar celebrating a completed daily quest. The title comes from the domain layer and is currently English
  ///
  /// In ru, this message translates to:
  /// **'Квест дня выполнен: {title} (+{xp, plural, one{{xp} очко} few{{xp} очка} many{{xp} очков} other{{xp} очков}})'**
  String challengeDailyCompletedToast(String title, int xp);

  /// Snack bar celebrating a completed weekly challenge. The title comes from the domain layer and is currently English
  ///
  /// In ru, this message translates to:
  /// **'Челлендж недели выполнен: {title} (+{xp, plural, one{{xp} очко} few{{xp} очка} many{{xp} очков} other{{xp} очков}})'**
  String challengeWeeklyCompletedToast(String title, int xp);

  /// Empty state for the category mastery list, encouraging the user to start logging
  ///
  /// In ru, this message translates to:
  /// **'Отмечай продукты — и прокачивай категории.'**
  String get masteryEmpty;

  /// Caption under a category that already reached the top (platinum) tier
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} порция отмечена} few{{count} порции отмечено} many{{count} порций отмечено} other{{count} порций отмечено}}'**
  String masteryServingsLogged(int count);

  /// Caption under a category progress bar, e.g. 12/25 servings to the next tier
  ///
  /// In ru, this message translates to:
  /// **'{current}/{target, plural, one{{target} порция} few{{target} порции} many{{target} порций} other{{target} порций}} до следующего уровня'**
  String masteryServingsToNextTier(int current, int target);

  /// Category mastery tier chip: bronze
  ///
  /// In ru, this message translates to:
  /// **'Бронза'**
  String get masteryTierBronze;

  /// Category mastery tier chip: silver
  ///
  /// In ru, this message translates to:
  /// **'Серебро'**
  String get masteryTierSilver;

  /// Category mastery tier chip: gold
  ///
  /// In ru, this message translates to:
  /// **'Золото'**
  String get masteryTierGold;

  /// Category mastery tier chip: platinum, the highest tier
  ///
  /// In ru, this message translates to:
  /// **'Платина'**
  String get masteryTierPlatinum;

  /// Uppercase pill at the top of the full-screen level-up celebration
  ///
  /// In ru, this message translates to:
  /// **'НОВЫЙ УРОВЕНЬ'**
  String get levelUpBadge;

  /// Big level number headline on the level-up celebration screen
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String levelUpLevel(int level);

  /// Warm subtitle under the new level title on the level-up celebration screen
  ///
  /// In ru, this message translates to:
  /// **'Твой росток стал ещё сильнее'**
  String get levelUpSubtitle;

  /// Button that dismisses the level-up celebration screen
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get levelUpContinue;

  /// Snack bar shown when a badge is unlocked. Both the emoji and the name come from the domain layer
  ///
  /// In ru, this message translates to:
  /// **'{emoji} Новая награда: {name}'**
  String badgeUnlockedToast(String emoji, String name);

  /// Placeholder name shown on a badge gallery tile that is not unlocked yet
  ///
  /// In ru, this message translates to:
  /// **'Закрыто'**
  String get badgeLocked;

  /// Encouraging empty state for the list of earned badges
  ///
  /// In ru, this message translates to:
  /// **'Пока нет наград — всё впереди!'**
  String get badgeEmpty;

  /// Full-screen loading message on the history/stats tab while the summary is being computed
  ///
  /// In ru, this message translates to:
  /// **'Считаем твой прогресс...'**
  String get historyLoading;

  /// Period heading on the history screen. Also reused as both trend chart titles and as the weekly stat card label. Replaces HistorySummary.periodLabel, which the data layer builds in hardcoded English.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Последний {count} день} few{Последние {count} дня} many{Последние {count} дней} other{Последние {count} дня}}'**
  String historyLastDays(int count);

  /// Encouraging subtitle right under the period heading on the history screen
  ///
  /// In ru, this message translates to:
  /// **'Смотри, как растёт твоя полезная привычка.'**
  String get historySubtitle;

  /// Headline of the paywall prompt shown instead of the history screen to non-premium users
  ///
  /// In ru, this message translates to:
  /// **'Полная статистика — в Premium'**
  String get historyPaywallTitle;

  /// Body text of the history paywall prompt explaining what Premium unlocks
  ///
  /// In ru, this message translates to:
  /// **'Отмечать полезные продукты можно бесплатно. С Premium ты увидишь тренды, серии, графики порций и прогресс за месяц.'**
  String get historyPaywallBody;

  /// Primary button on the history paywall prompt that opens the paywall sheet
  ///
  /// In ru, this message translates to:
  /// **'Посмотреть Premium'**
  String get historyPaywallCta;

  /// Secondary text button on the history paywall prompt that restores an existing purchase
  ///
  /// In ru, this message translates to:
  /// **'Я уже подписан — обновить'**
  String get historyPaywallRestore;

  /// Title of the monthly calendar heatmap card on the history screen. The month and year next to it come from intl DateFormat, not from ARB.
  ///
  /// In ru, this message translates to:
  /// **'Карта дней'**
  String get historyHeatmapTitle;

  /// Heatmap legend label for days where the daily goal was fully reached
  ///
  /// In ru, this message translates to:
  /// **'Цель выполнена'**
  String get historyLegendGoalMet;

  /// Heatmap legend label for days with some progress but the goal not reached
  ///
  /// In ru, this message translates to:
  /// **'Частично'**
  String get historyLegendPartial;

  /// Heatmap legend label for days with no log at all
  ///
  /// In ru, this message translates to:
  /// **'Нет записи'**
  String get historyLegendNoEntry;

  /// Tooltip shown when long-pressing a day cell in the heatmap. The date is already formatted by intl DateFormat.yMMMd; percent is pre-rounded to a whole number.
  ///
  /// In ru, this message translates to:
  /// **'{date}: {done}/{total} {total, plural, one{порция} few{порции} many{порций} other{порции}} ({percent}%)'**
  String historyHeatmapTooltip(
    String date,
    int done,
    int total,
    String percent,
  );

  /// Stat card label for the average completion percentage across the whole period
  ///
  /// In ru, this message translates to:
  /// **'Среднее за период'**
  String get historyAveragePeriod;

  /// Stat card subtitle: how many days out of the period hit the goal completely
  ///
  /// In ru, this message translates to:
  /// **'{done}/{total} {total, plural, one{полный день} few{полных дня} many{полных дней} other{полных дня}}'**
  String historyFullDays(int done, int total);

  /// Stat card label for the ongoing streak of goal-completed days
  ///
  /// In ru, this message translates to:
  /// **'Текущая серия'**
  String get historyCurrentStreak;

  /// Stat card subtitle under the current streak number. The number itself is rendered separately as the card value, so it must not be repeated here — only the noun agrees with it.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{день подряд} few{дня подряд} many{дней подряд} other{дня подряд}}'**
  String historyDaysInARow(int count);

  /// Stat card label for the all-time best streak
  ///
  /// In ru, this message translates to:
  /// **'Рекорд'**
  String get historyBestRecord;

  /// Stat card subtitle under the best streak number
  ///
  /// In ru, this message translates to:
  /// **'лучшая серия'**
  String get historyBestStreakSubtitle;

  /// Stat card subtitle under the last-7-days average completion percentage
  ///
  /// In ru, this message translates to:
  /// **'среднее за неделю'**
  String get historyWeeklyAverage;

  /// Title of the card on the profile screen that opens the challenges/progress screen
  ///
  /// In ru, this message translates to:
  /// **'Челленджи и награды'**
  String get profileChallengesTitle;

  /// Supporting line under profileChallengesTitle listing what the challenges screen contains
  ///
  /// In ru, this message translates to:
  /// **'Квесты, серии и все достижения'**
  String get profileChallengesSubtitle;

  /// Caption under the profile avatar: current level number and the level's name
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} · {title} 🌱'**
  String profileLevelCaption(int level, String title);

  /// Label under the big total-XP number in the profile stat card row
  ///
  /// In ru, this message translates to:
  /// **'всего очков'**
  String get profileStatTotalPoints;

  /// Label under the current-streak number in the profile stat card row. The number itself is rendered separately above the label, so it must not be repeated here — count only selects the plural form.
  ///
  /// In ru, this message translates to:
  /// **'{count,plural, one{🔥 день серия} few{🔥 дня серия} many{🔥 дней серия} other{🔥 дня серия}}'**
  String profileStatStreakDays(int count);

  /// Label under the longest-streak number in the profile stat card row
  ///
  /// In ru, this message translates to:
  /// **'🏆 рекорд'**
  String get profileStatRecord;

  /// Shown on the level progress card when the user has reached the highest level
  ///
  /// In ru, this message translates to:
  /// **'Максимальный уровень'**
  String get profileMaxLevel;

  /// Level progress card heading: how far it is to the next level and what that level is called
  ///
  /// In ru, this message translates to:
  /// **'До уровня {level} · {title}'**
  String profileNextLevel(int level, String title);

  /// Section header above the badge gallery on the profile screen
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get profileAchievements;

  /// Trailing counter next to the achievements section header: unlocked badges out of the total
  ///
  /// In ru, this message translates to:
  /// **'{unlocked} из {total}'**
  String profileAchievementsCount(int unlocked, int total);

  /// Title of the card showing seven dots, one per day of the current week
  ///
  /// In ru, this message translates to:
  /// **'Активность недели'**
  String get profileWeeklyActivity;

  /// Short weekday label under the Monday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get profileWeekdayMon;

  /// Short weekday label under the Tuesday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get profileWeekdayTue;

  /// Short weekday label under the Wednesday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get profileWeekdayWed;

  /// Short weekday label under the Thursday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get profileWeekdayThu;

  /// Short weekday label under the Friday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get profileWeekdayFri;

  /// Short weekday label under the Saturday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get profileWeekdaySat;

  /// Short weekday label under the Sunday dot of the weekly activity card
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get profileWeekdaySun;

  /// Footer link on the profile screen that opens the privacy policy in a browser
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get profilePrivacyPolicy;

  /// Footer link on the profile screen that opens the terms of use in a browser
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get profileTermsOfService;

  /// Snackbar shown when a legal link could not be opened in the browser
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть ссылку'**
  String get profileLinkOpenFailed;

  /// Destructive text button at the bottom of the profile screen
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get profileDeleteAccount;

  /// Title of the confirmation dialog for deleting the account
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get profileDeleteAccountConfirmTitle;

  /// Body of the account deletion dialog. Two paragraphs separated by a blank line: what gets erased, and the reminder that store subscriptions are billed separately. Keep the store names App Store / Play Store untranslated.
  ///
  /// In ru, this message translates to:
  /// **'Это навсегда удалит профиль, дневные записи, историю, прогресс и данные подписки. Отменить это будет нельзя.\n\nАктивные подписки App Store / Play Store при удалении аккаунта не отменяются — управляй ими в настройках подписок магазина.'**
  String get profileDeleteAccountConfirmBody;

  /// Snackbar shown when account deletion failed, followed by the raw error text from the backend
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить аккаунт: {message}'**
  String profileDeleteAccountFailed(String message);

  /// Generic dismiss button in dialogs
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// Generic destructive confirm button in dialogs
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// Default headline of the shared AppErrorState widget
  ///
  /// In ru, this message translates to:
  /// **'Не получилось загрузить'**
  String get commonErrorTitle;

  /// Default supporting copy of the shared AppErrorState widget. Informal second person.
  ///
  /// In ru, this message translates to:
  /// **'Проверь соединение и попробуй ещё раз'**
  String get commonErrorMessage;

  /// Default label of the retry button in the shared AppErrorState widget
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get commonRetry;

  /// Full-screen loading message on the home tab while today's tracker log is being fetched
  ///
  /// In ru, this message translates to:
  /// **'Готовим твой день...'**
  String get homeLoading;

  /// Text button under the daily challenge card that opens the AI coach screen
  ///
  /// In ru, this message translates to:
  /// **'AI-коуч'**
  String get homeAiCoach;

  /// Section header above the list of Daily-Dozen category tiles on the home tab
  ///
  /// In ru, this message translates to:
  /// **'Съедено сегодня'**
  String get homeEatenToday;

  /// Empty-state title on the home tab when the active filter matches no categories
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто'**
  String get homeEmptyTitle;

  /// Empty-state body on the home tab inviting the user to log a first serving
  ///
  /// In ru, this message translates to:
  /// **'Добавь первый полезный продукт и получи очки'**
  String get homeEmptyMessage;

  /// Text button at the bottom of the home tab that clears all servings logged today
  ///
  /// In ru, this message translates to:
  /// **'Сбросить день'**
  String get homeResetDay;

  /// Filter chip on the home tab showing every category. Keep it short — chips sit in one row
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get homeFilterAll;

  /// Filter chip on the home tab showing only categories that are not finished yet. Keep it short
  ///
  /// In ru, this message translates to:
  /// **'Осталось'**
  String get homeFilterRemaining;

  /// Filter chip on the home tab showing only finished categories. Keep it short
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get homeFilterDone;

  /// Home header greeting used when the user has not set a display name
  ///
  /// In ru, this message translates to:
  /// **'Привет! 🌱'**
  String get homeGreeting;

  /// Home header greeting used when the user has a display name
  ///
  /// In ru, this message translates to:
  /// **'Привет, {name} 🌱'**
  String homeGreetingNamed(String name);

  /// Home header headline under the greeting, asking what healthy food the user will eat today
  ///
  /// In ru, this message translates to:
  /// **'Что съедим полезного?'**
  String get homeGreetingQuestion;

  /// Subtitle of a single-serving category tile once the serving is logged
  ///
  /// In ru, this message translates to:
  /// **'Готово · +очки'**
  String get homeTileDone;

  /// Subtitle of a single-serving category tile prompting the user to tap the check button
  ///
  /// In ru, this message translates to:
  /// **'Нажми, чтобы отметить'**
  String get homeTileTapToMark;

  /// Screen-reader label for the minus button on a category tile. Not visible on screen
  ///
  /// In ru, this message translates to:
  /// **'Убрать порцию: {category}'**
  String homeRemoveServingSemantics(String category);

  /// Screen-reader label for the check button of a category whose target is already reached
  ///
  /// In ru, this message translates to:
  /// **'{category} — выполнено'**
  String homeCategoryCompletedSemantics(String category);

  /// Screen-reader label for the check button that logs one more serving, with current progress
  ///
  /// In ru, this message translates to:
  /// **'Добавить порцию: {category} ({completed} из {total})'**
  String homeAddServingSemantics(String category, int completed, int total);

  /// Caption under the big number inside the daily progress ring, naming the daily target
  ///
  /// In ru, this message translates to:
  /// **'из {goal}'**
  String homeProgressOfGoal(int goal);

  /// Badge on the home hero card showing the gamification level number and its title
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} · {title}'**
  String homeLevelBadge(int level, String title);

  /// Home hero card line telling how many servings are still missing today. The number is highlighted in the UI, so keep the count as a standalone number in the sentence
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Осталось {count} порция до цели дня} few{Осталось {count} порции до цели дня} many{Осталось {count} порций до цели дня} other{Осталось {count} порции до цели дня}}'**
  String homeRemainingServings(int count);

  /// Home hero card line replacing the remaining-servings sentence once the daily goal is met
  ///
  /// In ru, this message translates to:
  /// **'Цель дня выполнена!'**
  String get homeGoalReached;

  /// Home hero card line showing the current daily streak
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{🔥 {count} день подряд} few{🔥 {count} дня подряд} many{🔥 {count} дней подряд} other{🔥 {count} дня подряд}}'**
  String homeStreakDays(int count);

  /// Lowercase brand wordmark next to the dot logo on the auth and onboarding screens
  ///
  /// In ru, this message translates to:
  /// **'росток'**
  String get authBrandName;

  /// Primary submit button on the auth screen while it is in register mode
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get authCreateAccountButton;

  /// Primary submit button on the auth screen while it is in sign-in mode
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignInButton;

  /// Headline of the auth screen in register mode
  ///
  /// In ru, this message translates to:
  /// **'Создай аккаунт'**
  String get authRegisterHeadline;

  /// Headline of the auth screen in sign-in mode, welcoming a returning user
  ///
  /// In ru, this message translates to:
  /// **'С возвращением!'**
  String get authSignInHeadline;

  /// Subtitle under the auth headline in register mode
  ///
  /// In ru, this message translates to:
  /// **'Пара шагов — и начинаем игру.'**
  String get authRegisterSubtitle;

  /// Subtitle under the auth headline in sign-in mode. 'Росток' is the sprout mascot the user grows
  ///
  /// In ru, this message translates to:
  /// **'Продолжай прокачивать своего ростка.'**
  String get authSignInSubtitle;

  /// Left half of the segmented sign-in/register toggle. Keep it to one short word
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get authModeSignIn;

  /// Right half of the segmented sign-in/register toggle. Keep it to one short word
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get authModeRegister;

  /// Placeholder of the display-name field on the auth screen, shown only in register mode
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get authNameLabel;

  /// Inline validation error under the name field when it is empty or too short
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get authNameError;

  /// Placeholder of the email field on the auth screen
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get authEmailLabel;

  /// Inline validation error under the email field when the address is malformed
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную почту'**
  String get authEmailError;

  /// Placeholder of the password field on the auth screen
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPasswordLabel;

  /// Inline validation error under the password field stating the minimum length
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Минимум {count} символ} few{Минимум {count} символа} many{Минимум {count} символов} other{Минимум {count} символа}}'**
  String authPasswordError(int count);

  /// Screen-reader label for the eye button that reveals the typed password
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get authShowPassword;

  /// Screen-reader label for the eye button that masks the typed password
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get authHidePassword;

  /// Divider label between the email form and the Apple/Google buttons. Lowercase, one word
  ///
  /// In ru, this message translates to:
  /// **'или'**
  String get authDividerOr;

  /// Onboarding headline. The line break is intentional — keep both halves short and balanced
  ///
  /// In ru, this message translates to:
  /// **'Ешь полезное —\nнабирай очки'**
  String get onboardingTitle;

  /// Onboarding body copy explaining the loop: log foods, finish quests, level up
  ///
  /// In ru, this message translates to:
  /// **'Отмечай полезные продукты, выполняй квесты и выращивай свой уровень.'**
  String get onboardingSubtitle;

  /// Primary button that finishes onboarding and opens the home tab
  ///
  /// In ru, this message translates to:
  /// **'Начать игру'**
  String get onboardingStartButton;

  /// Loading message on the splash screen while the app decides where to route the user
  ///
  /// In ru, this message translates to:
  /// **'Растим твой росток...'**
  String get splashLoading;

  /// Fallback message on the splash screen when startup fails and the backend gave no reason
  ///
  /// In ru, this message translates to:
  /// **'Не получилось запустить приложение.'**
  String get splashStartupError;

  /// Header of the settings menu on the profile screen
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// Settings row that opens the language picker
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// Option meaning 'follow the device setting' for both language and theme
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get settingsSystemDefault;

  /// Settings row that opens the theme picker
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingsTheme;

  /// Light theme option
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settingsThemeDark;

  /// Settings row that opens account actions
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settingsAccount;

  /// Settings row that opens subscription management
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get settingsSubscription;

  /// Sign out action
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get settingsSignOut;

  /// Title of the sign-out confirmation dialog
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get settingsSignOutConfirmTitle;

  /// Reassuring body of the sign-out confirmation dialog
  ///
  /// In ru, this message translates to:
  /// **'Прогресс останется на сервере — просто войди снова.'**
  String get settingsSignOutConfirmBody;

  /// Subscription status when premium is active
  ///
  /// In ru, this message translates to:
  /// **'Stay Alive Pro активна'**
  String get settingsSubscriptionActive;

  /// Subscription status when the user has no premium
  ///
  /// In ru, this message translates to:
  /// **'Бесплатный план'**
  String get settingsSubscriptionFree;

  /// Renewal or expiry date of an active subscription
  ///
  /// In ru, this message translates to:
  /// **'Активна до {date}'**
  String settingsSubscriptionExpires(String date);

  /// Opens the store's subscription management page
  ///
  /// In ru, this message translates to:
  /// **'Управлять подпиской'**
  String get settingsManageSubscription;

  /// Restores an existing purchase on this device
  ///
  /// In ru, this message translates to:
  /// **'Восстановить покупки'**
  String get settingsRestorePurchases;

  /// Why the manage-subscription row is disabled for free users
  ///
  /// In ru, this message translates to:
  /// **'Доступно после оформления подписки'**
  String get settingsManageUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
