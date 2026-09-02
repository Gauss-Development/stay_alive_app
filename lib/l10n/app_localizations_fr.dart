// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Pousse';

  @override
  String get navHome => 'Accueil';

  @override
  String get navStats => 'Stats';

  @override
  String get navProfile => 'Profil';

  @override
  String get coachTitle => 'Coach IA';

  @override
  String get coachPaywallTitle =>
      'Le chat avec le coach fait partie de Stay Alive Pro';

  @override
  String get coachPaywallDescription =>
      'Conseils personnalisés, bilans de la semaine et quêtes du jardin. C\'est de la motivation Daily Dozen, pas un avis médical.';

  @override
  String get coachPaywallCta => 'Passer à Premium';

  @override
  String get coachChatDisclaimer =>
      'Le coach t\'aide à tenir l\'habitude Daily Dozen. Il ne remplace pas ton médecin.';

  @override
  String get coachChatEmptyHint =>
      'Demande ce qu\'il te reste à ajouter aujourd\'hui ou comment tenir ta série.';

  @override
  String get coachChatInputHint => 'Écris au coach…';

  @override
  String get coachWeeklyTitle => 'Bilan de la semaine';

  @override
  String get coachWeeklyRefresh => 'Actualiser';

  @override
  String get coachWeeklyPremiumCta => 'Les insights dans Stay Alive Pro';

  @override
  String get coachWeeklyRequestCta => 'Obtenir le bilan de la semaine';

  @override
  String get coachInsightUntitled => 'Insight';

  @override
  String get coachNudgeTitle => 'Coach de Pousse';

  @override
  String get coachNudgeOpenChat => 'Ouvrir le chat';

  @override
  String get coachNudgeLimitReached =>
      'Tu as utilisé tes conseils du jour. Ouvre le chat Pro.';

  @override
  String coachFallbackNudgeWilting(int streak) {
    return 'Ta pousse fane un peu — même une seule portion aujourd\'hui garde ta série en vie (actuellement : $streak).';
  }

  @override
  String coachFallbackNudgeNextStep(
    int completed,
    int target,
    String category,
  ) {
    return 'Beau progrès : $completed/$target. Prochaine étape — $category.';
  }

  @override
  String get coachFallbackNudgeAllDone =>
      'Toutes les catégories sont bouclées aujourd\'hui — ta pousse te dit merci !';

  @override
  String coachFallbackChatIntro(int streak) {
    return 'Je suis le coach de Pousse. Demande-moi ce qu\'il te reste à ajouter aujourd\'hui ou comment tenir ta série (actuellement : $streak). Je ne pose aucun diagnostic : je te motive seulement sur le Daily Dozen.';
  }

  @override
  String coachFallbackChatGaps(String categories, String levelTitle) {
    return 'D\'après tes relevés, il manque : $categories. Choisis une catégorie et coche une portion — les petits pas font monter ton niveau $levelTitle.';
  }

  @override
  String get coachFallbackChatAllDone =>
      'Tout est bouclé aujourd\'hui. Demain, vise un relevé tôt, avant 9h00 : ça rapporte des points bonus et ça soutient ta pousse.';

  @override
  String get coachFallbackWeeklyMessage => 'Ton bilan de la semaine est prêt.';

  @override
  String get coachFallbackWeeklyStreakTitle => 'Série';

  @override
  String coachFallbackWeeklyStreakBody(
    int streak,
    int activityStreak,
    String levelTitle,
  ) {
    return 'Série parfaite : $streak · jours actifs : $activityStreak. Niveau $levelTitle.';
  }

  @override
  String get coachFallbackWeeklyStreakKeepRhythm => 'garde le rythme';

  @override
  String get coachFallbackWeeklyStreakComeBack => 'reviens aujourd\'hui';

  @override
  String get coachFallbackWeeklyGapsTitle => 'Manques';

  @override
  String get coachFallbackWeeklyGapsNone =>
      'Les catégories du jour sont bouclées — un beau repère pour la semaine.';

  @override
  String coachFallbackWeeklyGapsList(String categories) {
    return 'Ce qui reste le plus souvent de côté : $categories.';
  }

  @override
  String get coachFallbackWeeklyAdviceTitle => 'Conseil du coach';

  @override
  String get coachFallbackWeeklyAdviceBody =>
      'Prévois 1–2 « ancres » (légumes verts + légumineuses) dans la première moitié de la journée.';

  @override
  String get coachFallbackChallengeMessage =>
      'Ta quête du jardin personnalisée pour aujourd\'hui.';

  @override
  String coachFallbackChallengeTitle(String category) {
    return 'Focus : $category';
  }

  @override
  String coachFallbackChallengeDescription(String category) {
    return 'Boucle la catégorie $category aujourd\'hui — ta pousse poussera plus forte.';
  }

  @override
  String coachFallbackEducationTip(String category) {
    return 'La catégorie « $category » fait partie du Daily Dozen. Ajoute les portions progressivement, sans règles de régime strictes. C\'est une habitude, pas un traitement.';
  }

  @override
  String get educationTitle => 'À savoir';

  @override
  String get educationLoading => 'On prépare ton conseil…';

  @override
  String get educationEmptyTitle => 'Bientôt du contenu intéressant';

  @override
  String educationEmptyMessage(String category) {
    return 'Le contenu sur la catégorie « $category » est en préparation.';
  }

  @override
  String get educationDisclaimer =>
      'Le conseil du coach, c\'est de la motivation Daily Dozen, pas un avis médical.';

  @override
  String get progressLoading => 'Chargement de tes quêtes...';

  @override
  String get progressTitle => 'Défis';

  @override
  String get progressSectionDaily => 'Quotidiens';

  @override
  String progressPremiumActive(num multiplier) {
    return 'Premium actif · ${multiplier}x points';
  }

  @override
  String get progressStreakPerfect => 'Série parfaite';

  @override
  String get progressStreakActive => 'Série active';

  @override
  String get progressStreakRecord => 'Ton record';

  @override
  String get progressPerfectDays => 'Jours parfaits';

  @override
  String get progressStreakFreezes => 'Gels';

  @override
  String get progressSectionAchievements => 'Réussites';

  @override
  String get progressSectionRecentBadges => 'Récompenses récentes';

  @override
  String get progressSectionCategories => 'Progression par catégorie';

  @override
  String get progressSectionXpHistory => 'Historique des points';

  @override
  String get progressGenerateQuest => 'Générer une quête du jardin';

  @override
  String get progressSproutWaiting => 'Ta pousse t\'attend aujourd\'hui';

  @override
  String get progressXpHistoryEmpty =>
      'L\'historique de tes points apparaîtra ici.';

  @override
  String progressLevelWithTitle(int level, String title) {
    return 'Niveau $level · $title';
  }

  @override
  String get challengeBadgeDailyPremium => 'Quête · Premium';

  @override
  String get challengeBadgeDaily => 'Quête du jour';

  @override
  String get challengeLockedDaily =>
      'Passe à Premium pour gagner des points bonus sur cette quête.';

  @override
  String get challengeDone => 'C\'est fait !';

  @override
  String get challengeBadgeWeekly => 'DÉFI DE LA SEMAINE';

  @override
  String get challengeLockedWeekly =>
      'Passe à Premium pour participer au défi de la semaine.';

  @override
  String get challengeCompleted => 'Terminé !';

  @override
  String challengeProgressOf(int progress, int target) {
    return '$progress sur $target';
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
    return 'Quête du jour réussie : $title (+$_temp0)';
  }

  @override
  String challengeWeeklyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp points',
      one: '$xp point',
    );
    return 'Défi de la semaine réussi : $title (+$_temp0)';
  }

  @override
  String get masteryEmpty =>
      'Note ce que tu manges — et fais monter tes catégories.';

  @override
  String masteryServingsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portions notées',
      one: '$count portion notée',
    );
    return '$_temp0';
  }

  @override
  String masteryServingsToNextTier(int current, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target portions',
      one: '$target portion',
    );
    return '$current/$_temp0 avant le niveau suivant';
  }

  @override
  String get masteryTierBronze => 'Bronze';

  @override
  String get masteryTierSilver => 'Argent';

  @override
  String get masteryTierGold => 'Or';

  @override
  String get masteryTierPlatinum => 'Platine';

  @override
  String get levelUpBadge => 'NOUVEAU NIVEAU';

  @override
  String levelUpLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get levelUpSubtitle => 'Ta pousse est devenue encore plus forte';

  @override
  String get levelUpContinue => 'Continuer';

  @override
  String badgeUnlockedToast(String emoji, String name) {
    return '$emoji Nouvelle récompense : $name';
  }

  @override
  String get badgeLocked => 'Verrouillé';

  @override
  String get badgeEmpty => 'Pas encore de récompenses — tout reste à venir !';

  @override
  String get historyLoading => 'On calcule ta progression...';

  @override
  String historyLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les $count derniers jours',
      one: 'Dernier jour',
    );
    return '$_temp0';
  }

  @override
  String get historySubtitle => 'Regarde ton habitude saine grandir.';

  @override
  String get historyPaywallTitle =>
      'Les statistiques complètes sont dans Premium';

  @override
  String get historyPaywallBody =>
      'Noter tes aliments sains est gratuit. Avec Premium, tu verras les tendances, les séries, les graphiques de portions et tout un mois de progression.';

  @override
  String get historyPaywallCta => 'Découvrir Premium';

  @override
  String get historyPaywallRestore => 'Je suis déjà abonné — actualiser';

  @override
  String get historyHeatmapTitle => 'Carte des jours';

  @override
  String get historyLegendGoalMet => 'Objectif atteint';

  @override
  String get historyLegendPartial => 'Partiel';

  @override
  String get historyLegendNoEntry => 'Aucune entrée';

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
      other: 'portions',
      one: 'portion',
    );
    return '$date : $done/$total $_temp0 ($percent %)';
  }

  @override
  String get historyAveragePeriod => 'Moyenne de la période';

  @override
  String historyFullDays(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'jours complets',
      one: 'jour complet',
    );
    return '$done/$total $_temp0';
  }

  @override
  String get historyCurrentStreak => 'Série en cours';

  @override
  String historyDaysInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours d’affilée',
      one: 'jour d’affilée',
    );
    return '$_temp0';
  }

  @override
  String get historyBestRecord => 'Record';

  @override
  String get historyBestStreakSubtitle => 'meilleure série';

  @override
  String get historyWeeklyAverage => 'moyenne hebdomadaire';

  @override
  String get profileChallengesTitle => 'Défis et récompenses';

  @override
  String get profileChallengesSubtitle => 'Quêtes, séries et tous les succès';

  @override
  String profileLevelCaption(int level, String title) {
    return 'Niveau $level · $title 🌱';
  }

  @override
  String get profileStatTotalPoints => 'points au total';

  @override
  String profileStatStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 jours de série',
      one: '🔥 jour de série',
    );
    return '$_temp0';
  }

  @override
  String get profileStatRecord => '🏆 record';

  @override
  String get profileMaxLevel => 'Niveau maximum atteint';

  @override
  String profileNextLevel(int level, String title) {
    return 'Vers le niveau $level · $title';
  }

  @override
  String get profileAchievements => 'Succès';

  @override
  String profileAchievementsCount(int unlocked, int total) {
    return '$unlocked sur $total';
  }

  @override
  String get profileWeeklyActivity => 'Ta semaine';

  @override
  String get profileWeekdayMon => 'Lun';

  @override
  String get profileWeekdayTue => 'Mar';

  @override
  String get profileWeekdayWed => 'Mer';

  @override
  String get profileWeekdayThu => 'Jeu';

  @override
  String get profileWeekdayFri => 'Ven';

  @override
  String get profileWeekdaySat => 'Sam';

  @override
  String get profileWeekdaySun => 'Dim';

  @override
  String get profilePrivacyPolicy => 'Politique de confidentialité';

  @override
  String get profileTermsOfService => 'Conditions d’utilisation';

  @override
  String get profileLinkOpenFailed => 'Impossible d’ouvrir le lien';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileDeleteAccountConfirmTitle => 'Supprimer ton compte ?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Cela effacera définitivement ton profil, tes entrées quotidiennes, ton historique, ta progression et tes données d’abonnement. Impossible de revenir en arrière.\n\nSupprimer ton compte n’annule pas un abonnement App Store / Play Store actif — gère-le dans les réglages d’abonnement de ta boutique.';

  @override
  String profileDeleteAccountFailed(String message) {
    return 'Impossible de supprimer ton compte : $message';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonErrorTitle => 'Le chargement a échoué';

  @override
  String get commonErrorMessage => 'Vérifie ta connexion et réessaie';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get homeLoading => 'On prépare ta journée...';

  @override
  String get homeAiCoach => 'Coach IA';

  @override
  String get homeEatenToday => 'Mangé aujourd’hui';

  @override
  String get homeEmptyTitle => 'Rien pour l’instant';

  @override
  String get homeEmptyMessage =>
      'Ajoute ton premier aliment sain et commence à gagner des points';

  @override
  String get homeResetDay => 'Réinitialiser la journée';

  @override
  String get homeFilterAll => 'Tout';

  @override
  String get homeFilterRemaining => 'Restants';

  @override
  String get homeFilterDone => 'Terminés';

  @override
  String get homeGreeting => 'Salut ! 🌱';

  @override
  String homeGreetingNamed(String name) {
    return 'Salut $name ! 🌱';
  }

  @override
  String get homeGreetingQuestion => 'On mange quoi de bon aujourd’hui ?';

  @override
  String get homeTileDone => 'Terminé · +points';

  @override
  String get homeTileTapToMark => 'Appuie pour cocher';

  @override
  String homeRemoveServingSemantics(String category) {
    return 'Retirer une portion : $category';
  }

  @override
  String homeCategoryCompletedSemantics(String category) {
    return '$category — terminé';
  }

  @override
  String homeAddServingSemantics(String category, int completed, int total) {
    return 'Ajouter une portion : $category ($completed sur $total)';
  }

  @override
  String homeProgressOfGoal(int goal) {
    return 'sur $goal';
  }

  @override
  String homeLevelBadge(int level, String title) {
    return 'Niveau $level · $title';
  }

  @override
  String homeRemainingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il te reste $count portions pour ton objectif du jour',
      one: 'Il te reste $count portion pour ton objectif du jour',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalReached => 'Objectif du jour atteint !';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count jours d’affilée',
      one: '🔥 $count jour d’affilée',
    );
    return '$_temp0';
  }

  @override
  String get authBrandName => 'sprout';

  @override
  String get authCreateAccountButton => 'Créer un compte';

  @override
  String get authSignInButton => 'Se connecter';

  @override
  String get authRegisterHeadline => 'Crée ton compte';

  @override
  String get authSignInHeadline => 'Content de te revoir !';

  @override
  String get authRegisterSubtitle => 'Encore deux étapes et le jeu commence.';

  @override
  String get authSignInSubtitle => 'Continue à faire grandir ta pousse.';

  @override
  String get authModeSignIn => 'Connexion';

  @override
  String get authModeRegister => 'Inscription';

  @override
  String get authNameLabel => 'Prénom';

  @override
  String get authNameError => 'Saisis ton prénom';

  @override
  String get authEmailLabel => 'Adresse e-mail';

  @override
  String get authEmailError => 'Saisis une adresse e-mail valide';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String authPasswordError(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Au moins $count caractères',
      one: 'Au moins $count caractère',
    );
    return '$_temp0';
  }

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get authDividerOr => 'ou';

  @override
  String get onboardingTitle => 'Mange sain —\ngagne des points';

  @override
  String get onboardingSubtitle =>
      'Coche les aliments sains, relève des quêtes et fais grandir ton niveau.';

  @override
  String get onboardingStartButton => 'Commencer le jeu';

  @override
  String get splashLoading => 'On fait grandir ta pousse...';

  @override
  String get splashStartupError => 'Impossible de lancer l’application.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSystemDefault => 'Comme le système';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get settingsSignOutConfirmBody =>
      'Ta progression reste sur le serveur — reconnecte-toi, c’est tout.';

  @override
  String get settingsSubscriptionActive => 'Stay Alive Pro est actif';

  @override
  String get settingsSubscriptionFree => 'Offre gratuite';

  @override
  String settingsSubscriptionExpires(String date) {
    return 'Actif jusqu’au $date';
  }

  @override
  String get settingsManageSubscription => 'Gérer l’abonnement';

  @override
  String get settingsRestorePurchases => 'Restaurer les achats';

  @override
  String get settingsManageUnavailable => 'Disponible une fois abonné';
}
