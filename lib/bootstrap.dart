import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stay_alive/app.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/env/load_env.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';

/// Shared startup for all entrypoints ([main_dev], [main_prod], default [main]).
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // The UI is Russian throughout. Without an explicit locale `DateFormat`
  // falls back to en_US and renders "3 Aug" on the history charts and badge
  // list, inside otherwise Russian screens.
  Intl.defaultLocale = 'ru';
  await initializeDateFormatting('ru');

  await loadEnvForFlavor(flavor);
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
