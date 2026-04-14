import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/router.dart';
import 'package:stay_alive/shared/theme/app_theme.dart';

class DailyDozenApp extends StatefulWidget {
  const DailyDozenApp({super.key});

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
        BlocProvider<DailyTrackerCubit>(
          create: (_) => sl<DailyTrackerCubit>(),
        ),
        BlocProvider<UserProfileCubit>(
          create: (_) => sl<UserProfileCubit>(),
        ),
        BlocProvider<HistoryCubit>(
          create: (_) => sl<HistoryCubit>(),
        ),
        BlocProvider<AnalyticsCubit>(
          create: (_) => sl<AnalyticsCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Daily Dozen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
