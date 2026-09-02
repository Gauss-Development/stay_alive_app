// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Brote';

  @override
  String get navHome => 'Inicio';

  @override
  String get navStats => 'Progreso';

  @override
  String get navProfile => 'Perfil';

  @override
  String get coachTitle => 'Coach IA';

  @override
  String get coachPaywallTitle =>
      'El chat con el coach es parte de Stay Alive Pro';

  @override
  String get coachPaywallDescription =>
      'Consejos personales, resúmenes de la semana y misiones del jardín. Es motivación del Daily Dozen, no una recomendación médica.';

  @override
  String get coachPaywallCta => 'Activar Premium';

  @override
  String get coachChatDisclaimer =>
      'El coach te acompaña con el hábito del Daily Dozen. No sustituye a tu médico.';

  @override
  String get coachChatEmptyHint =>
      'Pregunta qué te falta hoy o cómo mantener tu racha.';

  @override
  String get coachChatInputHint => 'Escríbele al coach…';

  @override
  String get coachWeeklyTitle => 'Resumen de la semana';

  @override
  String get coachWeeklyRefresh => 'Actualizar';

  @override
  String get coachWeeklyPremiumCta => 'Insights en Stay Alive Pro';

  @override
  String get coachWeeklyRequestCta => 'Ver el resumen de la semana';

  @override
  String get coachInsightUntitled => 'Insight';

  @override
  String get coachNudgeTitle => 'Coach de Brote';

  @override
  String get coachNudgeOpenChat => 'Abrir el chat';

  @override
  String get coachNudgeLimitReached =>
      'Ya usaste los consejos de hoy. Abre el chat Pro.';

  @override
  String coachFallbackNudgeWilting(int streak) {
    return 'Tu brote se está marchitando un poco: incluso una porción hoy mantiene viva tu racha (ahora: $streak).';
  }

  @override
  String coachFallbackNudgeNextStep(
    int completed,
    int target,
    String category,
  ) {
    return 'Buen avance: $completed/$target. El siguiente paso es $category.';
  }

  @override
  String get coachFallbackNudgeAllDone =>
      'Cerraste todas las categorías del día. ¡Tu brote te lo agradece!';

  @override
  String coachFallbackChatIntro(int streak) {
    return 'Soy el coach de Brote. Pregúntame qué te falta hoy o cómo mantener tu racha (ahora: $streak). No hago diagnósticos: solo te motivo con el Daily Dozen.';
  }

  @override
  String coachFallbackChatGaps(String categories, String levelTitle) {
    return 'Según tus registros te falta: $categories. Elige una categoría y marca una porción: los pasos pequeños suman a tu nivel $levelTitle.';
  }

  @override
  String get coachFallbackChatAllDone =>
      'Hoy está todo cerrado. Mañana intenta registrar temprano, antes de las 9:00: da puntos extra y cuida tu brote.';

  @override
  String get coachFallbackWeeklyMessage =>
      'Tu resumen de la semana está listo.';

  @override
  String get coachFallbackWeeklyStreakTitle => 'Racha';

  @override
  String coachFallbackWeeklyStreakBody(
    int streak,
    int activityStreak,
    String levelTitle,
  ) {
    return 'Racha perfecta: $streak · días activos: $activityStreak. Nivel $levelTitle.';
  }

  @override
  String get coachFallbackWeeklyStreakKeepRhythm => 'mantén el ritmo';

  @override
  String get coachFallbackWeeklyStreakComeBack => 'vuelve hoy';

  @override
  String get coachFallbackWeeklyGapsTitle => 'Huecos';

  @override
  String get coachFallbackWeeklyGapsNone =>
      'Hoy cerraste todas las categorías: un gran punto de referencia para la semana.';

  @override
  String coachFallbackWeeklyGapsList(String categories) {
    return 'Lo que más se queda pendiente: $categories.';
  }

  @override
  String get coachFallbackWeeklyAdviceTitle => 'Consejo del coach';

  @override
  String get coachFallbackWeeklyAdviceBody =>
      'Planifica 1–2 «anclas» (verduras + legumbres) en la primera mitad del día.';

  @override
  String get coachFallbackChallengeMessage =>
      'Tu misión personal del jardín para hoy.';

  @override
  String coachFallbackChallengeTitle(String category) {
    return 'Foco: $category';
  }

  @override
  String coachFallbackChallengeDescription(String category) {
    return 'Cierra hoy la categoría $category y tu brote crecerá más fuerte.';
  }

  @override
  String coachFallbackEducationTip(String category) {
    return 'La categoría «$category» forma parte del Daily Dozen. Suma porciones poco a poco, sin reglas de dieta estrictas. Es un hábito, no un tratamiento.';
  }

  @override
  String get educationTitle => 'Para saber';

  @override
  String get educationLoading => 'Preparando tu consejo…';

  @override
  String get educationEmptyTitle => 'Pronto habrá algo interesante';

  @override
  String educationEmptyMessage(String category) {
    return 'El material sobre la categoría «$category» ya está en camino.';
  }

  @override
  String get educationDisclaimer =>
      'El consejo del coach es motivación del Daily Dozen, no un consejo médico.';

  @override
  String get progressLoading => 'Cargando tus misiones...';

  @override
  String get progressTitle => 'Retos';

  @override
  String get progressSectionDaily => 'Diarios';

  @override
  String progressPremiumActive(num multiplier) {
    return 'Premium activo · ${multiplier}x puntos';
  }

  @override
  String get progressStreakPerfect => 'Racha perfecta';

  @override
  String get progressStreakActive => 'Racha activa';

  @override
  String get progressStreakRecord => 'Tu récord';

  @override
  String get progressPerfectDays => 'Días perfectos';

  @override
  String get progressStreakFreezes => 'Congelaciones';

  @override
  String get progressSectionAchievements => 'Logros';

  @override
  String get progressSectionRecentBadges => 'Recompensas recientes';

  @override
  String get progressSectionCategories => 'Progreso por categorías';

  @override
  String get progressSectionXpHistory => 'Historial de puntos';

  @override
  String get progressGenerateQuest => 'Generar misión del huerto';

  @override
  String get progressSproutWaiting => 'Tu brote te espera hoy';

  @override
  String get progressXpHistoryEmpty =>
      'Aquí aparecerá el historial de tus puntos.';

  @override
  String progressLevelWithTitle(int level, String title) {
    return 'Nivel $level · $title';
  }

  @override
  String get challengeBadgeDailyPremium => 'Misión · Premium';

  @override
  String get challengeBadgeDaily => 'Misión del día';

  @override
  String get challengeLockedDaily =>
      'Activa Premium para ganar puntos extra con esta misión.';

  @override
  String get challengeDone => '¡Listo!';

  @override
  String get challengeBadgeWeekly => 'RETO DE LA SEMANA';

  @override
  String get challengeLockedWeekly =>
      'Activa Premium para participar en el reto de la semana.';

  @override
  String get challengeCompleted => '¡Completado!';

  @override
  String challengeProgressOf(int progress, int target) {
    return '$progress de $target';
  }

  @override
  String challengeXpReward(int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp puntos',
      one: '$xp punto',
    );
    return '+$_temp0';
  }

  @override
  String challengeDailyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp puntos',
      one: '$xp punto',
    );
    return 'Misión del día completada: $title (+$_temp0)';
  }

  @override
  String challengeWeeklyCompletedToast(String title, int xp) {
    String _temp0 = intl.Intl.pluralLogic(
      xp,
      locale: localeName,
      other: '$xp puntos',
      one: '$xp punto',
    );
    return 'Reto de la semana completado: $title (+$_temp0)';
  }

  @override
  String get masteryEmpty =>
      'Registra lo que comes y sube de nivel en cada categoría.';

  @override
  String masteryServingsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count raciones registradas',
      one: '$count ración registrada',
    );
    return '$_temp0';
  }

  @override
  String masteryServingsToNextTier(int current, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target raciones',
      one: '$target ración',
    );
    return '$current/$_temp0 para el siguiente nivel';
  }

  @override
  String get masteryTierBronze => 'Bronce';

  @override
  String get masteryTierSilver => 'Plata';

  @override
  String get masteryTierGold => 'Oro';

  @override
  String get masteryTierPlatinum => 'Platino';

  @override
  String get levelUpBadge => 'NUEVO NIVEL';

  @override
  String levelUpLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get levelUpSubtitle => 'Tu brote se ha hecho más fuerte';

  @override
  String get levelUpContinue => 'Continuar';

  @override
  String badgeUnlockedToast(String emoji, String name) {
    return '$emoji Nueva recompensa: $name';
  }

  @override
  String get badgeLocked => 'Bloqueado';

  @override
  String get badgeEmpty => 'Aún no hay recompensas: ¡todas están por llegar!';

  @override
  String get historyLoading => 'Calculando tu progreso...';

  @override
  String historyLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Últimos $count días',
      one: 'Último día',
    );
    return '$_temp0';
  }

  @override
  String get historySubtitle => 'Mira cómo crece tu hábito saludable.';

  @override
  String get historyPaywallTitle =>
      'Las estadísticas completas están en Premium';

  @override
  String get historyPaywallBody =>
      'Registrar alimentos saludables es gratis. Con Premium verás tendencias, rachas, gráficos de porciones y todo un mes de progreso.';

  @override
  String get historyPaywallCta => 'Ver Premium';

  @override
  String get historyPaywallRestore => 'Ya estoy suscrito: actualizar';

  @override
  String get historyHeatmapTitle => 'Mapa de días';

  @override
  String get historyLegendGoalMet => 'Objetivo cumplido';

  @override
  String get historyLegendPartial => 'Parcial';

  @override
  String get historyLegendNoEntry => 'Sin registro';

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
      other: 'porciones',
      one: 'porción',
    );
    return '$date: $done/$total $_temp0 ($percent %)';
  }

  @override
  String get historyAveragePeriod => 'Media del periodo';

  @override
  String historyFullDays(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'días completos',
      one: 'día completo',
    );
    return '$done/$total $_temp0';
  }

  @override
  String get historyCurrentStreak => 'Racha actual';

  @override
  String historyDaysInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días seguidos',
      one: 'día seguido',
    );
    return '$_temp0';
  }

  @override
  String get historyBestRecord => 'Récord';

  @override
  String get historyBestStreakSubtitle => 'mejor racha';

  @override
  String get historyWeeklyAverage => 'media semanal';

  @override
  String get profileChallengesTitle => 'Retos y recompensas';

  @override
  String get profileChallengesSubtitle => 'Misiones, rachas y todos los logros';

  @override
  String profileLevelCaption(int level, String title) {
    return 'Nivel $level · $title 🌱';
  }

  @override
  String get profileStatTotalPoints => 'puntos totales';

  @override
  String profileStatStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 días de racha',
      one: '🔥 día de racha',
    );
    return '$_temp0';
  }

  @override
  String get profileStatRecord => '🏆 récord';

  @override
  String get profileMaxLevel => 'Nivel máximo alcanzado';

  @override
  String profileNextLevel(int level, String title) {
    return 'Hasta el nivel $level · $title';
  }

  @override
  String get profileAchievements => 'Logros';

  @override
  String profileAchievementsCount(int unlocked, int total) {
    return '$unlocked de $total';
  }

  @override
  String get profileWeeklyActivity => 'Tu semana';

  @override
  String get profileWeekdayMon => 'Lun';

  @override
  String get profileWeekdayTue => 'Mar';

  @override
  String get profileWeekdayWed => 'Mié';

  @override
  String get profileWeekdayThu => 'Jue';

  @override
  String get profileWeekdayFri => 'Vie';

  @override
  String get profileWeekdaySat => 'Sáb';

  @override
  String get profileWeekdaySun => 'Dom';

  @override
  String get profilePrivacyPolicy => 'Política de privacidad';

  @override
  String get profileTermsOfService => 'Términos de uso';

  @override
  String get profileLinkOpenFailed => 'No se pudo abrir el enlace';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountConfirmTitle => '¿Eliminar tu cuenta?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Esto borrará para siempre tu perfil, tus registros diarios, el historial, tu progreso y los datos de suscripción. No se puede deshacer.\n\nEliminar la cuenta no cancela una suscripción activa de App Store / Play Store: gestiónala desde los ajustes de suscripciones de la tienda.';

  @override
  String profileDeleteAccountFailed(String message) {
    return 'No se pudo eliminar tu cuenta: $message';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonErrorTitle => 'No se pudo cargar';

  @override
  String get commonErrorMessage => 'Revisa tu conexión e inténtalo de nuevo';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get homeLoading => 'Preparando tu día...';

  @override
  String get homeAiCoach => 'Coach IA';

  @override
  String get homeEatenToday => 'Comido hoy';

  @override
  String get homeEmptyTitle => 'Todavía no hay nada';

  @override
  String get homeEmptyMessage =>
      'Añade tu primer alimento saludable y empieza a ganar puntos';

  @override
  String get homeResetDay => 'Reiniciar el día';

  @override
  String get homeFilterAll => 'Todos';

  @override
  String get homeFilterRemaining => 'Pendientes';

  @override
  String get homeFilterDone => 'Hechos';

  @override
  String get homeGreeting => '¡Hola! 🌱';

  @override
  String homeGreetingNamed(String name) {
    return '¡Hola, $name! 🌱';
  }

  @override
  String get homeGreetingQuestion => '¿Qué comemos sano hoy?';

  @override
  String get homeTileDone => 'Hecho · +puntos';

  @override
  String get homeTileTapToMark => 'Toca para marcarlo';

  @override
  String homeRemoveServingSemantics(String category) {
    return 'Quitar una ración: $category';
  }

  @override
  String homeCategoryCompletedSemantics(String category) {
    return '$category — completado';
  }

  @override
  String homeAddServingSemantics(String category, int completed, int total) {
    return 'Añadir una ración: $category ($completed de $total)';
  }

  @override
  String homeProgressOfGoal(int goal) {
    return 'de $goal';
  }

  @override
  String homeLevelBadge(int level, String title) {
    return 'Nivel $level · $title';
  }

  @override
  String homeRemainingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te quedan $count raciones para el objetivo del día',
      one: 'Te queda $count ración para el objetivo del día',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalReached => '¡Objetivo del día cumplido!';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 $count días seguidos',
      one: '🔥 $count día seguido',
    );
    return '$_temp0';
  }

  @override
  String get authBrandName => 'sprout';

  @override
  String get authCreateAccountButton => 'Crear cuenta';

  @override
  String get authSignInButton => 'Entrar';

  @override
  String get authRegisterHeadline => 'Crea tu cuenta';

  @override
  String get authSignInHeadline => '¡Qué bien verte de vuelta!';

  @override
  String get authRegisterSubtitle => 'Un par de pasos y empieza el juego.';

  @override
  String get authSignInSubtitle => 'Sigue haciendo crecer tu brote.';

  @override
  String get authModeSignIn => 'Entrar';

  @override
  String get authModeRegister => 'Registro';

  @override
  String get authNameLabel => 'Nombre';

  @override
  String get authNameError => 'Escribe tu nombre';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailError => 'Escribe un correo válido';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String authPasswordError(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mínimo $count caracteres',
      one: 'Mínimo $count carácter',
    );
    return '$_temp0';
  }

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authDividerOr => 'o';

  @override
  String get onboardingTitle => 'Come sano —\ngana puntos';

  @override
  String get onboardingSubtitle =>
      'Marca los alimentos saludables, completa misiones y haz crecer tu nivel.';

  @override
  String get onboardingStartButton => 'Empezar el juego';

  @override
  String get splashLoading => 'Cultivando tu brote...';

  @override
  String get splashStartupError => 'No hemos podido iniciar la aplicación.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSystemDefault => 'Según el sistema';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsSubscription => 'Suscripción';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsSignOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get settingsSignOutConfirmBody =>
      'Tu progreso se queda en el servidor: solo vuelve a entrar.';

  @override
  String get settingsSubscriptionActive => 'Stay Alive Pro activa';

  @override
  String get settingsSubscriptionFree => 'Plan gratuito';

  @override
  String settingsSubscriptionExpires(String date) {
    return 'Activa hasta el $date';
  }

  @override
  String get settingsManageSubscription => 'Gestionar suscripción';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsManageUnavailable => 'Disponible al suscribirte';
}
