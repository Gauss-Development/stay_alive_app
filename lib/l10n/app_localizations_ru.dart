// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Росток';

  @override
  String get navHome => 'Главная';

  @override
  String get navStats => 'Статистика';

  @override
  String get navProfile => 'Профиль';

  @override
  String get coachTitle => 'AI-коуч';

  @override
  String get coachPaywallTitle => 'Чат с коучем — часть Stay Alive Pro';

  @override
  String get coachPaywallDescription =>
      'Персональные советы, разборы недели и квесты сада. Это мотивация по Daily Dozen, не медицинские рекомендации.';

  @override
  String get coachPaywallCta => 'Открыть Premium';

  @override
  String get coachChatDisclaimer =>
      'Коуч помогает с привычкой Daily Dozen. Не заменяет врача.';

  @override
  String get coachChatEmptyHint =>
      'Спроси, что добрать сегодня или как удержать серию.';

  @override
  String get coachChatInputHint => 'Напиши коучу…';

  @override
  String get coachWeeklyTitle => 'Недельный разбор';

  @override
  String get coachWeeklyRefresh => 'Обновить';

  @override
  String get coachWeeklyPremiumCta => 'Инсайты в Stay Alive Pro';

  @override
  String get coachWeeklyRequestCta => 'Получить разбор недели';

  @override
  String get coachInsightUntitled => 'Инсайт';

  @override
  String get coachNudgeTitle => 'Коуч Ростка';

  @override
  String get coachNudgeOpenChat => 'Открыть чат';

  @override
  String get coachNudgeLimitReached =>
      'Дневной лимит подсказок исчерпан. Открой Pro-чат.';

  @override
  String coachFallbackNudgeWilting(int streak) {
    return 'Росток слегка вянет — даже одна порция сегодня поддержит серию (сейчас $streak дн.).';
  }

  @override
  String coachFallbackNudgeNextStep(
    int completed,
    int target,
    String category,
  ) {
    return 'Отличный прогресс: $completed/$target. Следующий шаг — $category.';
  }

  @override
  String get coachFallbackNudgeAllDone =>
      'День закрыт по всем категориям — росток благодарен!';

  @override
  String coachFallbackChatIntro(int streak) {
    return 'Я коуч «Ростка». Спроси, что добрать сегодня, или как удержать серию (сейчас $streak дн.). Я не ставлю диагнозов — только мотивацию по Daily Dozen.';
  }

  @override
  String coachFallbackChatGaps(String categories, String levelTitle) {
    return 'По твоим логам не хватает: $categories. Выбери одну категорию и отметь порцию — маленькие шаги копят уровень $levelTitle.';
  }

  @override
  String get coachFallbackChatAllDone =>
      'Сегодня всё закрыто. Завтра сфокусируйся на раннем логе до 9:00 — это даёт бонусные очки и поддерживает росток.';

  @override
  String get coachFallbackWeeklyMessage => 'Недельный разбор готов.';

  @override
  String get coachFallbackWeeklyStreakTitle => 'Серия';

  @override
  String coachFallbackWeeklyStreakBody(
    int streak,
    int activityStreak,
    String levelTitle,
  ) {
    return 'Идеальная серия: $streak дн., активность: $activityStreak дн. Уровень $levelTitle.';
  }

  @override
  String get coachFallbackWeeklyStreakKeepRhythm => 'держи ритм';

  @override
  String get coachFallbackWeeklyStreakComeBack => 'вернись сегодня';

  @override
  String get coachFallbackWeeklyGapsTitle => 'Пробелы';

  @override
  String get coachFallbackWeeklyGapsNone =>
      'Категории сегодня закрыты — отличный ориентир на неделю.';

  @override
  String coachFallbackWeeklyGapsList(String categories) {
    return 'Чаще всего остаются: $categories.';
  }

  @override
  String get coachFallbackWeeklyAdviceTitle => 'Совет коуча';

  @override
  String get coachFallbackWeeklyAdviceBody =>
      'Планируй 1–2 «якоря» (зелень + бобы) в первой половине дня.';

  @override
  String get coachFallbackChallengeMessage =>
      'Персональный квест сада на сегодня.';

  @override
  String coachFallbackChallengeTitle(String category) {
    return 'Фокус: $category';
  }

  @override
  String coachFallbackChallengeDescription(String category) {
    return 'Закрой категорию $category сегодня — росток вырастет крепче.';
  }

  @override
  String coachFallbackEducationTip(String category) {
    return 'Категория «$category» — часть Daily Dozen. Добавляй порции постепенно, без жёстких диетических правил. Это привычка, не лечение.';
  }

  @override
  String get educationTitle => 'Полезное';

  @override
  String get educationLoading => 'Готовим подсказку…';

  @override
  String get educationEmptyTitle => 'Скоро здесь будет интересно';

  @override
  String educationEmptyMessage(String category) {
    return 'Материалы о категории «$category» уже готовятся.';
  }

  @override
  String get educationDisclaimer =>
      'Подсказка коуча — мотивация по Daily Dozen, не медицинский совет.';

  @override
  String get progressLoading => 'Загружаем квесты...';

  @override
  String get progressTitle => 'Челленджи';

  @override
  String get progressSectionDaily => 'Ежедневные';

  @override
  String progressPremiumActive(num multiplier) {
    return 'Premium активен · ${multiplier}x очков';
  }

  @override
  String get progressStreakPerfect => 'Идеальная серия';

  @override
  String get progressStreakActive => 'Активная серия';

  @override
  String get progressStreakRecord => 'Рекорд';

  @override
  String get progressPerfectDays => 'Идеальные дни';

  @override
  String get progressStreakFreezes => 'Заморозки';

  @override
  String get progressSectionAchievements => 'Достижения';

  @override
  String get progressSectionRecentBadges => 'Недавние награды';

  @override
  String get progressSectionCategories => 'Прогресс по категориям';

  @override
  String get progressSectionXpHistory => 'История очков';

  @override
  String get progressGenerateQuest => 'Сгенерировать квест сада';

  @override
  String get progressSproutWaiting => 'Росток ждёт тебя сегодня';

  @override
  String get progressXpHistoryEmpty => 'Здесь появится история твоих очков.';

  @override
  String progressLevelWithTitle(int level, String title) {
    return 'Уровень $level · $title';
  }

  @override
  String get challengeBadgeDailyPremium => 'Квест · Premium';

  @override
  String get challengeBadgeDaily => 'Квест дня';

  @override
  String get challengeLockedDaily =>
      'Открой Premium, чтобы получать бонусные очки за этот квест.';

  @override
  String get challengeDone => 'Готово!';

  @override
  String get challengeBadgeWeekly => 'ЧЕЛЛЕНДЖ НЕДЕЛИ';

  @override
  String get challengeLockedWeekly =>
      'Открой Premium, чтобы участвовать в недельном челлендже.';

  @override
  String get challengeCompleted => 'Выполнено!';

  @override
  String challengeProgressOf(int progress, int target) {
    return '$progress из $target';
  }

  @override
  String challengeXpReward(int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp очков',
      many: '$xp очков',
      few: '$xp очка',
      one: '$xp очко',
    );
    return '+$_temp0';
  }

  @override
  String challengeDailyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp очков',
      many: '$xp очков',
      few: '$xp очка',
      one: '$xp очко',
    );
    return 'Квест дня выполнен: $title (+$_temp0)';
  }

  @override
  String challengeWeeklyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp очков',
      many: '$xp очков',
      few: '$xp очка',
      one: '$xp очко',
    );
    return 'Челлендж недели выполнен: $title (+$_temp0)';
  }

  @override
  String get masteryEmpty => 'Отмечай продукты — и прокачивай категории.';

  @override
  String masteryServingsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count порций отмечено',
      many: '$count порций отмечено',
      few: '$count порции отмечено',
      one: '$count порция отмечена',
    );
    return '$_temp0';
  }

  @override
  String masteryServingsToNextTier(int current, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target порций',
      many: '$target порций',
      few: '$target порции',
      one: '$target порция',
    );
    return '$current/$_temp0 до следующего уровня';
  }

  @override
  String get masteryTierBronze => 'Бронза';

  @override
  String get masteryTierSilver => 'Серебро';

  @override
  String get masteryTierGold => 'Золото';

  @override
  String get masteryTierPlatinum => 'Платина';

  @override
  String get levelUpBadge => 'НОВЫЙ УРОВЕНЬ';

  @override
  String levelUpLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get levelUpSubtitle => 'Твой росток стал ещё сильнее';

  @override
  String get levelUpContinue => 'Продолжить';

  @override
  String badgeUnlockedToast(String emoji, String name) {
    return '$emoji Новая награда: $name';
  }

  @override
  String get badgeLocked => 'Закрыто';

  @override
  String get badgeEmpty => 'Пока нет наград — всё впереди!';

  @override
  String get historyLoading => 'Считаем твой прогресс...';

  @override
  String historyLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Последние $count дня',
      many: 'Последние $count дней',
      few: 'Последние $count дня',
      one: 'Последний $count день',
    );
    return '$_temp0';
  }

  @override
  String get historySubtitle => 'Смотри, как растёт твоя полезная привычка.';

  @override
  String get historyPaywallTitle => 'Полная статистика — в Premium';

  @override
  String get historyPaywallBody =>
      'Отмечать полезные продукты можно бесплатно. С Premium ты увидишь тренды, серии, графики порций и прогресс за месяц.';

  @override
  String get historyPaywallCta => 'Посмотреть Premium';

  @override
  String get historyPaywallRestore => 'Я уже подписан — обновить';

  @override
  String get historyHeatmapTitle => 'Карта дней';

  @override
  String get historyLegendGoalMet => 'Цель выполнена';

  @override
  String get historyLegendPartial => 'Частично';

  @override
  String get historyLegendNoEntry => 'Нет записи';

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
      other: 'порции',
      many: 'порций',
      few: 'порции',
      one: 'порция',
    );
    return '$date: $done/$total $_temp0 ($percent%)';
  }

  @override
  String get historyAveragePeriod => 'Среднее за период';

  @override
  String historyFullDays(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'полных дня',
      many: 'полных дней',
      few: 'полных дня',
      one: 'полный день',
    );
    return '$done/$total $_temp0';
  }

  @override
  String get historyCurrentStreak => 'Текущая серия';

  @override
  String historyDaysInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дня подряд',
      many: 'дней подряд',
      few: 'дня подряд',
      one: 'день подряд',
    );
    return '$_temp0';
  }

  @override
  String get historyBestRecord => 'Рекорд';

  @override
  String get historyBestStreakSubtitle => 'лучшая серия';

  @override
  String get historyWeeklyAverage => 'среднее за неделю';

  @override
  String get profileChallengesTitle => 'Челленджи и награды';

  @override
  String get profileChallengesSubtitle => 'Квесты, серии и все достижения';

  @override
  String profileLevelCaption(int level, String title) {
    return 'Уровень $level · $title 🌱';
  }

  @override
  String get profileStatTotalPoints => 'всего очков';

  @override
  String profileStatStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 дня серия',
      many: '🔥 дней серия',
      few: '🔥 дня серия',
      one: '🔥 день серия',
    );
    return '$_temp0';
  }

  @override
  String get profileStatRecord => '🏆 рекорд';

  @override
  String get profileMaxLevel => 'Максимальный уровень';

  @override
  String profileNextLevel(int level, String title) {
    return 'До уровня $level · $title';
  }

  @override
  String get profileAchievements => 'Достижения';

  @override
  String profileAchievementsCount(int unlocked, int total) {
    return '$unlocked из $total';
  }

  @override
  String get profileWeeklyActivity => 'Активность недели';

  @override
  String get profileWeekdayMon => 'Пн';

  @override
  String get profileWeekdayTue => 'Вт';

  @override
  String get profileWeekdayWed => 'Ср';

  @override
  String get profileWeekdayThu => 'Чт';

  @override
  String get profileWeekdayFri => 'Пт';

  @override
  String get profileWeekdaySat => 'Сб';

  @override
  String get profileWeekdaySun => 'Вс';

  @override
  String get profilePrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get profileTermsOfService => 'Условия использования';

  @override
  String get profileLinkOpenFailed => 'Не удалось открыть ссылку';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountConfirmTitle => 'Удалить аккаунт?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Это навсегда удалит профиль, дневные записи, историю, прогресс и данные подписки. Отменить это будет нельзя.\n\nАктивные подписки App Store / Play Store при удалении аккаунта не отменяются — управляй ими в настройках подписок магазина.';

  @override
  String profileDeleteAccountFailed(String message) {
    return 'Не удалось удалить аккаунт: $message';
  }

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonErrorTitle => 'Не получилось загрузить';

  @override
  String get commonErrorMessage => 'Проверь соединение и попробуй ещё раз';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get homeLoading => 'Готовим твой день...';

  @override
  String get homeAiCoach => 'AI-коуч';

  @override
  String get homeEatenToday => 'Съедено сегодня';

  @override
  String get homeEmptyTitle => 'Пока пусто';

  @override
  String get homeEmptyMessage => 'Добавь первый полезный продукт и получи очки';

  @override
  String get homeResetDay => 'Сбросить день';

  @override
  String get homeFilterAll => 'Все';

  @override
  String get homeFilterRemaining => 'Осталось';

  @override
  String get homeFilterDone => 'Готово';

  @override
  String get homeGreeting => 'Привет! 🌱';

  @override
  String homeGreetingNamed(String name) {
    return 'Привет, $name 🌱';
  }

  @override
  String get homeGreetingQuestion => 'Что съедим полезного?';

  @override
  String get homeTileDone => 'Готово · +очки';

  @override
  String get homeTileTapToMark => 'Нажми, чтобы отметить';

  @override
  String homeRemoveServingSemantics(String category) {
    return 'Убрать порцию: $category';
  }

  @override
  String homeCategoryCompletedSemantics(String category) {
    return '$category — выполнено';
  }

  @override
  String homeAddServingSemantics(String category, int completed, int total) {
    return 'Добавить порцию: $category ($completed из $total)';
  }

  @override
  String homeProgressOfGoal(int goal) {
    return 'из $goal';
  }

  @override
  String homeLevelBadge(int level, String title) {
    return 'Уровень $level · $title';
  }

  @override
  String homeRemainingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count порции до цели дня',
      many: 'Осталось $count порций до цели дня',
      few: 'Осталось $count порции до цели дня',
      one: 'Осталось $count порция до цели дня',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalReached => 'Цель дня выполнена!';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count дня подряд',
      many: '🔥 $count дней подряд',
      few: '🔥 $count дня подряд',
      one: '🔥 $count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get authBrandName => 'росток';

  @override
  String get authCreateAccountButton => 'Создать аккаунт';

  @override
  String get authSignInButton => 'Войти';

  @override
  String get authRegisterHeadline => 'Создай аккаунт';

  @override
  String get authSignInHeadline => 'С возвращением!';

  @override
  String get authRegisterSubtitle => 'Пара шагов — и начинаем игру.';

  @override
  String get authSignInSubtitle => 'Продолжай прокачивать своего ростка.';

  @override
  String get authModeSignIn => 'Вход';

  @override
  String get authModeRegister => 'Регистрация';

  @override
  String get authNameLabel => 'Имя';

  @override
  String get authNameError => 'Введите имя';

  @override
  String get authEmailLabel => 'Электронная почта';

  @override
  String get authEmailError => 'Введите корректную почту';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String authPasswordError(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Минимум $count символа',
      many: 'Минимум $count символов',
      few: 'Минимум $count символа',
      one: 'Минимум $count символ',
    );
    return '$_temp0';
  }

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authDividerOr => 'или';

  @override
  String get onboardingTitle => 'Ешь полезное —\nнабирай очки';

  @override
  String get onboardingSubtitle =>
      'Отмечай полезные продукты, выполняй квесты и выращивай свой уровень.';

  @override
  String get onboardingStartButton => 'Начать игру';

  @override
  String get splashLoading => 'Растим твой росток...';

  @override
  String get splashStartupError => 'Не получилось запустить приложение.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSystemDefault => 'Как в системе';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsSubscription => 'Подписка';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsSignOutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get settingsSignOutConfirmBody =>
      'Прогресс останется на сервере — просто войди снова.';

  @override
  String get settingsSubscriptionActive => 'Stay Alive Pro активна';

  @override
  String get settingsSubscriptionFree => 'Бесплатный план';

  @override
  String settingsSubscriptionExpires(String date) {
    return 'Активна до $date';
  }

  @override
  String get settingsManageSubscription => 'Управлять подпиской';

  @override
  String get settingsRestorePurchases => 'Восстановить покупки';

  @override
  String get settingsManageUnavailable => 'Доступно после оформления подписки';
}
