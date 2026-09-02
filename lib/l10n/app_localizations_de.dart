// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Sprössling';

  @override
  String get navHome => 'Start';

  @override
  String get navStats => 'Statistik';

  @override
  String get navProfile => 'Profil';

  @override
  String get coachTitle => 'KI-Coach';

  @override
  String get coachPaywallTitle =>
      'Der Chat mit dem Coach gehört zu Stay Alive Pro';

  @override
  String get coachPaywallDescription =>
      'Persönliche Tipps, Wochenrückblicke und Garten-Quests. Das ist Daily-Dozen-Motivation, keine medizinische Empfehlung.';

  @override
  String get coachPaywallCta => 'Premium freischalten';

  @override
  String get coachChatDisclaimer =>
      'Der Coach hilft dir bei der Daily-Dozen-Gewohnheit. Er ersetzt keine Ärztin und keinen Arzt.';

  @override
  String get coachChatEmptyHint =>
      'Frag, was dir heute noch fehlt oder wie du deine Serie hältst.';

  @override
  String get coachChatInputHint => 'Schreib dem Coach…';

  @override
  String get coachWeeklyTitle => 'Wochenrückblick';

  @override
  String get coachWeeklyRefresh => 'Aktualisieren';

  @override
  String get coachWeeklyPremiumCta => 'Insights in Stay Alive Pro';

  @override
  String get coachWeeklyRequestCta => 'Wochenrückblick anzeigen';

  @override
  String get coachInsightUntitled => 'Insight';

  @override
  String get coachNudgeTitle => 'Sprössling-Coach';

  @override
  String get coachNudgeOpenChat => 'Chat öffnen';

  @override
  String get coachNudgeLimitReached =>
      'Deine Tipps für heute sind aufgebraucht. Öffne den Pro-Chat.';

  @override
  String coachFallbackNudgeWilting(int streak) {
    return 'Dein Sprössling lässt die Blätter etwas hängen — schon eine Portion heute hält deine Serie am Leben (aktuell: $streak).';
  }

  @override
  String coachFallbackNudgeNextStep(
    int completed,
    int target,
    String category,
  ) {
    return 'Starker Fortschritt: $completed/$target. Als Nächstes — $category.';
  }

  @override
  String get coachFallbackNudgeAllDone =>
      'Heute sind alle Kategorien abgehakt — dein Sprössling sagt danke!';

  @override
  String coachFallbackChatIntro(int streak) {
    return 'Ich bin der Sprössling-Coach. Frag mich, was dir heute noch fehlt oder wie du deine Serie hältst (aktuell: $streak). Ich stelle keine Diagnosen — ich motiviere dich nur beim Daily Dozen.';
  }

  @override
  String coachFallbackChatGaps(String categories, String levelTitle) {
    return 'Laut deinen Einträgen fehlt noch: $categories. Such dir eine Kategorie aus und hak eine Portion ab — kleine Schritte bringen dein Level $levelTitle voran.';
  }

  @override
  String get coachFallbackChatAllDone =>
      'Heute ist alles abgehakt. Trag dich morgen früh ein, vor 9:00 Uhr — das gibt Bonuspunkte und tut deinem Sprössling gut.';

  @override
  String get coachFallbackWeeklyMessage => 'Dein Wochenrückblick ist fertig.';

  @override
  String get coachFallbackWeeklyStreakTitle => 'Serie';

  @override
  String coachFallbackWeeklyStreakBody(
    int streak,
    int activityStreak,
    String levelTitle,
  ) {
    return 'Perfekte Serie: $streak · aktive Tage: $activityStreak. Level $levelTitle.';
  }

  @override
  String get coachFallbackWeeklyStreakKeepRhythm => 'bleib im Rhythmus';

  @override
  String get coachFallbackWeeklyStreakComeBack => 'komm heute zurück';

  @override
  String get coachFallbackWeeklyGapsTitle => 'Lücken';

  @override
  String get coachFallbackWeeklyGapsNone =>
      'Heute sind alle Kategorien abgehakt — ein guter Maßstab für die Woche.';

  @override
  String coachFallbackWeeklyGapsList(String categories) {
    return 'Am häufigsten bleibt liegen: $categories.';
  }

  @override
  String get coachFallbackWeeklyAdviceTitle => 'Tipp vom Coach';

  @override
  String get coachFallbackWeeklyAdviceBody =>
      'Plane 1–2 „Anker“ (Grünzeug + Hülsenfrüchte) für die erste Tageshälfte.';

  @override
  String get coachFallbackChallengeMessage =>
      'Deine persönliche Garten-Quest für heute.';

  @override
  String coachFallbackChallengeTitle(String category) {
    return 'Fokus: $category';
  }

  @override
  String coachFallbackChallengeDescription(String category) {
    return 'Hak heute die Kategorie $category ab — dein Sprössling wird kräftiger.';
  }

  @override
  String coachFallbackEducationTip(String category) {
    return 'Die Kategorie „$category“ gehört zum Daily Dozen. Ergänze die Portionen nach und nach, ohne strenge Diätregeln. Das ist eine Gewohnheit, keine Behandlung.';
  }

  @override
  String get educationTitle => 'Wissenswertes';

  @override
  String get educationLoading => 'Dein Tipp wird vorbereitet…';

  @override
  String get educationEmptyTitle => 'Hier wird es bald spannend';

  @override
  String educationEmptyMessage(String category) {
    return 'Material zur Kategorie „$category“ ist schon in Arbeit.';
  }

  @override
  String get educationDisclaimer =>
      'Der Tipp vom Coach ist Daily-Dozen-Motivation, kein medizinischer Rat.';

  @override
  String get progressLoading => 'Deine Quests werden geladen ...';

  @override
  String get progressTitle => 'Challenges';

  @override
  String get progressSectionDaily => 'Täglich';

  @override
  String progressPremiumActive(num multiplier) {
    return 'Premium aktiv · ${multiplier}x Punkte';
  }

  @override
  String get progressStreakPerfect => 'Perfekte Serie';

  @override
  String get progressStreakActive => 'Aktive Serie';

  @override
  String get progressStreakRecord => 'Dein Rekord';

  @override
  String get progressPerfectDays => 'Perfekte Tage';

  @override
  String get progressStreakFreezes => 'Freezes';

  @override
  String get progressSectionAchievements => 'Erfolge';

  @override
  String get progressSectionRecentBadges => 'Neueste Belohnungen';

  @override
  String get progressSectionCategories => 'Fortschritt nach Kategorien';

  @override
  String get progressSectionXpHistory => 'Punkteverlauf';

  @override
  String get progressGenerateQuest => 'Garten-Quest erzeugen';

  @override
  String get progressSproutWaiting => 'Dein Sprössling wartet heute auf dich';

  @override
  String get progressXpHistoryEmpty =>
      'Hier erscheint der Verlauf deiner Punkte.';

  @override
  String progressLevelWithTitle(int level, String title) {
    return 'Level $level · $title';
  }

  @override
  String get challengeBadgeDailyPremium => 'Quest · Premium';

  @override
  String get challengeBadgeDaily => 'Quest des Tages';

  @override
  String get challengeLockedDaily =>
      'Hol dir Premium und sammle Bonuspunkte für diese Quest.';

  @override
  String get challengeDone => 'Geschafft!';

  @override
  String get challengeBadgeWeekly => 'CHALLENGE DER WOCHE';

  @override
  String get challengeLockedWeekly =>
      'Hol dir Premium und mach bei der Wochen-Challenge mit.';

  @override
  String get challengeCompleted => 'Erledigt!';

  @override
  String challengeProgressOf(int progress, int target) {
    return '$progress von $target';
  }

  @override
  String challengeXpReward(int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp Punkte',
      one: '$xp Punkt',
    );
    return '+$_temp0';
  }

  @override
  String challengeDailyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp Punkte',
      one: '$xp Punkt',
    );
    return 'Tages-Quest geschafft: $title (+$_temp0)';
  }

  @override
  String challengeWeeklyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp Punkte',
      one: '$xp Punkt',
    );
    return 'Wochen-Challenge geschafft: $title (+$_temp0)';
  }

  @override
  String get masteryEmpty =>
      'Trag ein, was du isst — und bring deine Kategorien nach oben.';

  @override
  String masteryServingsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Portionen erfasst',
      one: '$count Portion erfasst',
    );
    return '$_temp0';
  }

  @override
  String masteryServingsToNextTier(int current, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target Portionen',
      one: '$target Portion',
    );
    return '$current/$_temp0 bis zur nächsten Stufe';
  }

  @override
  String get masteryTierBronze => 'Bronze';

  @override
  String get masteryTierSilver => 'Silber';

  @override
  String get masteryTierGold => 'Gold';

  @override
  String get masteryTierPlatinum => 'Platin';

  @override
  String get levelUpBadge => 'NEUES LEVEL';

  @override
  String levelUpLevel(int level) {
    return 'Level $level';
  }

  @override
  String get levelUpSubtitle => 'Dein Sprössling ist noch stärker geworden';

  @override
  String get levelUpContinue => 'Weiter';

  @override
  String badgeUnlockedToast(String emoji, String name) {
    return '$emoji Neue Belohnung: $name';
  }

  @override
  String get badgeLocked => 'Gesperrt';

  @override
  String get badgeEmpty => 'Noch keine Belohnungen — alles liegt noch vor dir!';

  @override
  String get historyLoading => 'Wir zählen deinen Fortschritt...';

  @override
  String historyLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Letzte $count Tage',
      one: 'Letzter Tag',
    );
    return '$_temp0';
  }

  @override
  String get historySubtitle =>
      'Schau zu, wie deine gesunde Gewohnheit wächst.';

  @override
  String get historyPaywallTitle => 'Alle Statistiken gibt es mit Premium';

  @override
  String get historyPaywallBody =>
      'Gesunde Lebensmittel einzutragen ist kostenlos. Mit Premium siehst du Trends, Serien, Portionsdiagramme und einen ganzen Monat Fortschritt.';

  @override
  String get historyPaywallCta => 'Premium ansehen';

  @override
  String get historyPaywallRestore => 'Ich bin schon Abonnent — aktualisieren';

  @override
  String get historyHeatmapTitle => 'Tageskarte';

  @override
  String get historyLegendGoalMet => 'Ziel erreicht';

  @override
  String get historyLegendPartial => 'Teilweise';

  @override
  String get historyLegendNoEntry => 'Kein Eintrag';

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
      other: 'Portionen',
      one: 'Portion',
    );
    return '$date: $done/$total $_temp0 ($percent %)';
  }

  @override
  String get historyAveragePeriod => 'Durchschnitt im Zeitraum';

  @override
  String historyFullDays(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'volle Tage',
      one: 'voller Tag',
    );
    return '$done/$total $_temp0';
  }

  @override
  String get historyCurrentStreak => 'Aktuelle Serie';

  @override
  String historyDaysInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage in Folge',
      one: 'Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String get historyBestRecord => 'Rekord';

  @override
  String get historyBestStreakSubtitle => 'beste Serie';

  @override
  String get historyWeeklyAverage => 'Wochendurchschnitt';

  @override
  String get profileChallengesTitle => 'Challenges & Belohnungen';

  @override
  String get profileChallengesSubtitle => 'Quests, Serien und alle Erfolge';

  @override
  String profileLevelCaption(int level, String title) {
    return 'Level $level · $title 🌱';
  }

  @override
  String get profileStatTotalPoints => 'Punkte gesamt';

  @override
  String profileStatStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 Tage Serie',
      one: '🔥 Tag Serie',
    );
    return '$_temp0';
  }

  @override
  String get profileStatRecord => '🏆 Rekord';

  @override
  String get profileMaxLevel => 'Höchstes Level erreicht';

  @override
  String profileNextLevel(int level, String title) {
    return 'Bis Level $level · $title';
  }

  @override
  String get profileAchievements => 'Erfolge';

  @override
  String profileAchievementsCount(int unlocked, int total) {
    return '$unlocked von $total';
  }

  @override
  String get profileWeeklyActivity => 'Deine Woche';

  @override
  String get profileWeekdayMon => 'Mo';

  @override
  String get profileWeekdayTue => 'Di';

  @override
  String get profileWeekdayWed => 'Mi';

  @override
  String get profileWeekdayThu => 'Do';

  @override
  String get profileWeekdayFri => 'Fr';

  @override
  String get profileWeekdaySat => 'Sa';

  @override
  String get profileWeekdaySun => 'So';

  @override
  String get profilePrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get profileTermsOfService => 'Nutzungsbedingungen';

  @override
  String get profileLinkOpenFailed => 'Der Link konnte nicht geöffnet werden';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profileDeleteAccountConfirmTitle => 'Konto wirklich löschen?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Damit löschst du dein Profil, deine Tageseinträge, den Verlauf, deinen Fortschritt und alle Abo-Daten für immer. Rückgängig machen geht nicht.\n\nEin aktives App Store / Play Store Abo wird durch das Löschen deines Kontos nicht gekündigt — verwalte es in den Abo-Einstellungen deines Stores.';

  @override
  String profileDeleteAccountFailed(String message) {
    return 'Konto konnte nicht gelöscht werden: $message';
  }

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonErrorTitle => 'Laden fehlgeschlagen';

  @override
  String get commonErrorMessage =>
      'Prüf deine Verbindung und versuch es nochmal';

  @override
  String get commonRetry => 'Nochmal versuchen';

  @override
  String get homeLoading => 'Wir machen deinen Tag startklar...';

  @override
  String get homeAiCoach => 'KI-Coach';

  @override
  String get homeEatenToday => 'Heute gegessen';

  @override
  String get homeEmptyTitle => 'Hier ist noch nichts';

  @override
  String get homeEmptyMessage =>
      'Füge dein erstes gesundes Lebensmittel hinzu und sammle Punkte';

  @override
  String get homeResetDay => 'Tag zurücksetzen';

  @override
  String get homeFilterAll => 'Alle';

  @override
  String get homeFilterRemaining => 'Offen';

  @override
  String get homeFilterDone => 'Erledigt';

  @override
  String get homeGreeting => 'Hi! 🌱';

  @override
  String homeGreetingNamed(String name) {
    return 'Hi, $name 🌱';
  }

  @override
  String get homeGreetingQuestion => 'Was Gesundes essen wir heute?';

  @override
  String get homeTileDone => 'Erledigt · +Punkte';

  @override
  String get homeTileTapToMark => 'Tippe zum Abhaken';

  @override
  String homeRemoveServingSemantics(String category) {
    return 'Portion entfernen: $category';
  }

  @override
  String homeCategoryCompletedSemantics(String category) {
    return '$category — erledigt';
  }

  @override
  String homeAddServingSemantics(String category, int completed, int total) {
    return 'Portion hinzufügen: $category ($completed von $total)';
  }

  @override
  String homeProgressOfGoal(int goal) {
    return 'von $goal';
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
      other: 'Noch $count Portionen bis zu deinem Tagesziel',
      one: 'Noch $count Portion bis zu deinem Tagesziel',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalReached => 'Tagesziel geschafft!';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count Tage in Folge',
      one: '🔥 $count Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String get authBrandName => 'sprout';

  @override
  String get authCreateAccountButton => 'Konto erstellen';

  @override
  String get authSignInButton => 'Anmelden';

  @override
  String get authRegisterHeadline => 'Erstelle dein Konto';

  @override
  String get authSignInHeadline => 'Schön, dass du wieder da bist!';

  @override
  String get authRegisterSubtitle =>
      'Nur zwei Schritte, dann geht das Spiel los.';

  @override
  String get authSignInSubtitle => 'Lass deinen Sprössling weiter wachsen.';

  @override
  String get authModeSignIn => 'Login';

  @override
  String get authModeRegister => 'Registrieren';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authNameError => 'Gib deinen Namen ein';

  @override
  String get authEmailLabel => 'E-Mail-Adresse';

  @override
  String get authEmailError => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String authPasswordError(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mindestens $count Zeichen',
      one: 'Mindestens $count Zeichen',
    );
    return '$_temp0';
  }

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get authDividerOr => 'oder';

  @override
  String get onboardingTitle => 'Iss gesund —\nsammle Punkte';

  @override
  String get onboardingSubtitle =>
      'Hake gesunde Lebensmittel ab, erledige Quests und lass dein Level wachsen.';

  @override
  String get onboardingStartButton => 'Spiel starten';

  @override
  String get splashLoading => 'Wir lassen deinen Sprössling wachsen...';

  @override
  String get splashStartupError => 'Die App konnte nicht gestartet werden.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSystemDefault => 'Systemeinstellung';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsSubscription => 'Abo';

  @override
  String get settingsSignOut => 'Abmelden';

  @override
  String get settingsSignOutConfirmTitle => 'Wirklich abmelden?';

  @override
  String get settingsSignOutConfirmBody =>
      'Dein Fortschritt bleibt auf dem Server — melde dich einfach wieder an.';

  @override
  String get settingsSubscriptionActive => 'Stay Alive Pro ist aktiv';

  @override
  String get settingsSubscriptionFree => 'Kostenloser Plan';

  @override
  String settingsSubscriptionExpires(String date) {
    return 'Aktiv bis $date';
  }

  @override
  String get settingsManageSubscription => 'Abo verwalten';

  @override
  String get settingsRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get settingsManageUnavailable => 'Verfügbar, sobald du ein Abo hast';
}
