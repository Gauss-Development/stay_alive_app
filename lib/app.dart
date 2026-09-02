import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/gamification_celebration_host.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/router.dart';
import 'package:stay_alive/core/settings/app_settings.dart';
import 'package:stay_alive/core/settings/settings_cubit.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_theme.dart';

class DailyDozenApp extends StatefulWidget {
  const DailyDozenApp({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  State<DailyDozenApp> createState() => _DailyDozenAppState();
}

class _DailyDozenAppState extends State<DailyDozenApp> {
  late final AuthCubit _authCubit = sl<AuthCubit>();
  late final AppStartupCubit _startupCubit = sl<AppStartupCubit>();
  late final GoRouter _router = createRouter(_authCubit);

  @override
  void initState() {
    super.initState();
    _startupCubit.initialize();
  }

  @override
  void dispose() {
    _router.dispose();
    _startupCubit.close();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<AppStartupCubit>.value(value: _startupCubit),
        BlocProvider<DailyTrackerCubit>(create: (_) => sl<DailyTrackerCubit>()),
        BlocProvider<GamificationCubit>(create: (_) => sl<GamificationCubit>()),
        BlocProvider<CoachCubit>(create: (_) => sl<CoachCubit>()),
        BlocProvider<UserProfileCubit>(create: (_) => sl<UserProfileCubit>()),
        BlocProvider<HistoryCubit>(create: (_) => sl<HistoryCubit>()),
        BlocProvider<AnalyticsCubit>(create: (_) => sl<AnalyticsCubit>()),
        BlocProvider<SubscriptionCubit>(create: (_) => sl<SubscriptionCubit>()),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (BuildContext context, AppSettings settings) {
          return MaterialApp.router(
            onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            // Null means "follow the device" — Flutter then resolves against
            // supportedLocales exactly as it did before the picker existed.
            locale: settings.locale,
            themeMode: settings.themeMode,
            routerConfig: _router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: supportedLocales,
            builder: (BuildContext context, Widget? child) {
              // `intl` formats dates through a global, so keep it in step with
              // the locale Flutter actually resolved for this build.
              Intl.defaultLocale = Localizations.localeOf(context).languageCode;
              return GamificationCelebrationHost(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
