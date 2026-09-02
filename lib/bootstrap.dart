import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stay_alive/app.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/env/load_env.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared startup for all entrypoints ([main_dev], [main_prod], default [main]).
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Date symbols for every shipped locale. `MaterialApp.builder` then pins
  // `Intl.defaultLocale` to whichever one Flutter resolves, so charts and
  // badge dates never fall back to en_US inside a translated screen.
  await initializeDateFormatting();
  Intl.defaultLocale = supportedLocales.first.languageCode;

  await loadEnvForFlavor(flavor);

  final EnvConfig bootEnv = EnvConfig.fromEnv(flavor);
  if (bootEnv.supabaseUrl.isEmpty || bootEnv.supabaseAnonKey.isEmpty) {
    // Production resolves the committed dev fallbacks to '' (fail closed) —
    // a release build without injected SUPABASE_* must never ship silently
    // pointed at a dev backend.
    throw StateError(
      'SUPABASE_URL / SUPABASE_ANON_KEY are not configured for the '
      '${flavor.name} flavor. Inject them via --dart-define or assets/env.',
    );
  }
  await Supabase.initialize(
    url: bootEnv.supabaseUrl,
    publishableKey: bootEnv.supabaseAnonKey,
  );

  await configureDependencies(flavor);
  await sl<DailyGoalWidgetService>().initialize();

  final EnvConfig env = sl<EnvConfig>();
  if (env.sentryDsn.isEmpty) {
    runApp(DailyDozenApp(flavor: flavor));
    return;
  }

  await SentryFlutter.init((SentryFlutterOptions options) {
    options.dsn = env.sentryDsn;
    options.environment = env.sentryEnvironment;
    options.tracesSampleRate = flavor.isProduction ? 0.2 : 1.0;
    options.sendDefaultPii = false;
  }, appRunner: () => runApp(DailyDozenApp(flavor: flavor)));
}
