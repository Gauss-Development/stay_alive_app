import 'package:get_it/get_it.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/logger/logger_service.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stay_alive/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:stay_alive/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_oauth_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/logout_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/daily_tracker/data/datasources/daily_tracker_remote_data_source.dart';
import 'package:stay_alive/features/daily_tracker/data/repositories_impl/daily_tracker_repository_impl.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/decrement_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_completion_summary_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/increment_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/initialize_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/reset_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/data/repositories_impl/gamification_repository_impl.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_overview_usecase.dart';
import 'package:stay_alive/features/gamification/domain/usecases/reconcile_gamification_today_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/coach/data/datasources/coach_remote_data_source.dart';
import 'package:stay_alive/features/coach/data/repositories_impl/coach_repository_impl.dart';
import 'package:stay_alive/features/coach/domain/repositories/coach_repository.dart';
import 'package:stay_alive/features/coach/domain/usecases/invoke_coach_usecase.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:stay_alive/features/analytics/data/repositories_impl/analytics_repository_impl.dart';
import 'package:stay_alive/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:stay_alive/features/analytics/domain/usecases/track_event_usecase.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/history/data/datasources/history_remote_data_source.dart';
import 'package:stay_alive/features/history/data/repositories_impl/history_repository_impl.dart';
import 'package:stay_alive/features/history/domain/repositories/history_repository.dart';
import 'package:stay_alive/features/history/domain/usecases/get_history_summary_usecase.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/subscription/data/datasources/revenue_cat_subscription_data_source.dart';
import 'package:stay_alive/features/subscription/data/repositories_impl/subscription_repository_impl.dart';
import 'package:stay_alive/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:stay_alive/features/subscription/domain/usecases/get_subscription_offering_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/get_subscription_status_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:stay_alive/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/data/datasources/user_remote_data_source.dart';
import 'package:stay_alive/features/user/data/repositories_impl/user_repository_impl.dart';
import 'package:stay_alive/features/user/domain/repositories/user_repository.dart';
import 'package:stay_alive/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies(AppFlavor flavor) async {
  await sl.reset();
  sl.registerSingleton<AppFlavor>(flavor);
  _registerCore();
  _registerAuthFeature();
  _registerDailyTrackerFeature();
  _registerGamificationFeature();
  _registerCoachFeature();
  _registerUserFeature();
  _registerHistoryFeature();
  _registerAnalyticsFeature();
  _registerSubscriptionFeature();
}

void _registerCore() {
  sl
    ..registerLazySingleton<EnvConfig>(() => EnvConfig.fromEnv(sl<AppFlavor>()))
    ..registerLazySingleton<AppLogger>(() => const LoggerService())
    // Supabase.initialize() runs in bootstrap before configureDependencies.
    ..registerLazySingleton<SupabaseClient>(() => Supabase.instance.client)
    ..registerLazySingleton<GoTrueClient>(() => sl<SupabaseClient>().auth)
    ..registerLazySingleton<FunctionsClient>(
      () => sl<SupabaseClient>().functions,
    )
    ..registerLazySingleton<HomeWidgetGateway>(
      () => const HomeWidgetPluginGateway(),
    )
    ..registerLazySingleton<DailyGoalWidgetService>(
      () => DailyGoalWidgetService(
        gateway: sl<HomeWidgetGateway>(),
        envConfig: sl<EnvConfig>(),
      ),
    );
}

void _registerAuthFeature() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => SupabaseAuthRemoteDataSource(
        client: sl<SupabaseClient>(),
        auth: sl<GoTrueClient>(),
        functions: sl<FunctionsClient>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<AppLogger>()),
    )
    ..registerLazySingleton<LoginWithEmailUseCase>(
      () => LoginWithEmailUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<SignUpWithEmailUseCase>(
      () => SignUpWithEmailUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<CheckSessionUseCase>(
      () => CheckSessionUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<LoginWithOAuthUseCase>(
      () => LoginWithOAuthUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<DeleteAccountUseCase>(
      () => DeleteAccountUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<SignInAnonymouslyUseCase>(
      () => SignInAnonymouslyUseCase(sl<AuthRepository>()),
    )
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        loginWithEmailUseCase: sl<LoginWithEmailUseCase>(),
        signUpWithEmailUseCase: sl<SignUpWithEmailUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        loginWithOAuthUseCase: sl<LoginWithOAuthUseCase>(),
        completeOnboardingUseCase: sl<CompleteOnboardingUseCase>(),
        deleteAccountUseCase: sl<DeleteAccountUseCase>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerFactory<AppStartupCubit>(
      () => AppStartupCubit(
        checkSessionUseCase: sl<CheckSessionUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        logger: sl<AppLogger>(),
      ),
    );
}

void _registerDailyTrackerFeature() {
  sl
    ..registerLazySingleton<DailyTrackerRemoteDataSource>(
      () => SupabaseDailyTrackerRemoteDataSource(
        client: sl<SupabaseClient>(),
        auth: sl<GoTrueClient>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerLazySingleton<DailyTrackerRepository>(
      () => DailyTrackerRepositoryImpl(sl<DailyTrackerRemoteDataSource>()),
    )
    ..registerLazySingleton<GetTodayLogUseCase>(
      () => GetTodayLogUseCase(sl<DailyTrackerRepository>()),
    )
    ..registerLazySingleton<InitializeTodayLogUseCase>(
      () => InitializeTodayLogUseCase(sl<DailyTrackerRepository>()),
    )
    ..registerLazySingleton<IncrementCategoryProgressUseCase>(
      () => IncrementCategoryProgressUseCase(sl<DailyTrackerRepository>()),
    )
    ..registerLazySingleton<DecrementCategoryProgressUseCase>(
      () => DecrementCategoryProgressUseCase(sl<DailyTrackerRepository>()),
    )
    ..registerLazySingleton<ResetTodayLogUseCase>(
      () => ResetTodayLogUseCase(sl<DailyTrackerRepository>()),
    )
    ..registerLazySingleton<GetCompletionSummaryUseCase>(
      () => const GetCompletionSummaryUseCase(),
    )
    ..registerFactory<DailyTrackerCubit>(
      () => DailyTrackerCubit(
        getTodayLogUseCase: sl<GetTodayLogUseCase>(),
        initializeTodayLogUseCase: sl<InitializeTodayLogUseCase>(),
        incrementCategoryProgressUseCase:
            sl<IncrementCategoryProgressUseCase>(),
        decrementCategoryProgressUseCase:
            sl<DecrementCategoryProgressUseCase>(),
        resetTodayLogUseCase: sl<ResetTodayLogUseCase>(),
        getCompletionSummaryUseCase: sl<GetCompletionSummaryUseCase>(),
        logger: sl<AppLogger>(),
      ),
    );
}

void _registerUserFeature() {
  sl
    ..registerLazySingleton<UserRemoteDataSource>(
      () => SupabaseUserRemoteDataSource(
        client: sl<SupabaseClient>(),
        auth: sl<GoTrueClient>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(sl<UserRemoteDataSource>()),
    )
    ..registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(sl<UserRepository>()),
    )
    ..registerFactory<UserProfileCubit>(
      () =>
          UserProfileCubit(getUserProfileUseCase: sl<GetUserProfileUseCase>()),
    );
}

void _registerGamificationFeature() {
  sl
    ..registerLazySingleton<GamificationRemoteDataSource>(
      () => SupabaseGamificationRemoteDataSource(
        client: sl<SupabaseClient>(),
        auth: sl<GoTrueClient>(),
      ),
    )
    ..registerLazySingleton<GamificationRepository>(
      () => GamificationRepositoryImpl(sl<GamificationRemoteDataSource>()),
    )
    ..registerLazySingleton<ReconcileGamificationOverviewUseCase>(
      () => ReconcileGamificationOverviewUseCase(sl<GamificationRepository>()),
    )
    ..registerLazySingleton<ReconcileGamificationTodayUseCase>(
      () => ReconcileGamificationTodayUseCase(sl<GamificationRepository>()),
    )
    ..registerFactory<GamificationCubit>(
      () => GamificationCubit(
        reconcileGamificationOverviewUseCase:
            sl<ReconcileGamificationOverviewUseCase>(),
        reconcileGamificationTodayUseCase:
            sl<ReconcileGamificationTodayUseCase>(),
      ),
    );
}

void _registerCoachFeature() {
  sl
    ..registerLazySingleton<CoachRemoteDataSource>(
      () => CoachRemoteDataSourceImpl(
        functions: sl<FunctionsClient>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerLazySingleton<CoachRepository>(
      () => CoachRepositoryImpl(sl<CoachRemoteDataSource>()),
    )
    ..registerLazySingleton<InvokeCoachUseCase>(
      () => InvokeCoachUseCase(sl<CoachRepository>()),
    )
    ..registerFactory<CoachCubit>(
      () => CoachCubit(sl<InvokeCoachUseCase>()),
    );
}

void _registerHistoryFeature() {
  sl
    ..registerLazySingleton<HistoryRemoteDataSource>(
      () => SupabaseHistoryRemoteDataSource(
        client: sl<SupabaseClient>(),
        auth: sl<GoTrueClient>(),
      ),
    )
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(sl<HistoryRemoteDataSource>()),
    )
    ..registerLazySingleton<GetHistorySummaryUseCase>(
      () => GetHistorySummaryUseCase(sl<HistoryRepository>()),
    )
    ..registerFactory<HistoryCubit>(
      () => HistoryCubit(
        getHistorySummaryUseCase: sl<GetHistorySummaryUseCase>(),
      ),
    );
}

void _registerAnalyticsFeature() {
  sl
    ..registerLazySingleton<AnalyticsRemoteDataSource>(
      () => SupabaseAnalyticsRemoteDataSource(
        client: sl<SupabaseClient>(),
        auth: sl<GoTrueClient>(),
      ),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(sl<AnalyticsRemoteDataSource>()),
    )
    ..registerLazySingleton<TrackEventUseCase>(
      () => TrackEventUseCase(sl<AnalyticsRepository>()),
    )
    ..registerFactory<AnalyticsCubit>(
      () => AnalyticsCubit(sl<TrackEventUseCase>()),
    );
}

void _registerSubscriptionFeature() {
  sl
    ..registerLazySingleton<RevenueCatGateway>(
      () => const PurchasesRevenueCatGateway(),
    )
    ..registerLazySingleton<SubscriptionRemoteDataSource>(
      () => RevenueCatSubscriptionRemoteDataSource(
        revenueCatGateway: sl<RevenueCatGateway>(),
        auth: sl<GoTrueClient>(),
        envConfig: sl<EnvConfig>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl<SubscriptionRemoteDataSource>()),
    )
    ..registerLazySingleton<GetSubscriptionStatusUseCase>(
      () => GetSubscriptionStatusUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton<GetSubscriptionOfferingUseCase>(
      () => GetSubscriptionOfferingUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton<PurchaseSubscriptionUseCase>(
      () => PurchaseSubscriptionUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton<RestorePurchasesUseCase>(
      () => RestorePurchasesUseCase(sl<SubscriptionRepository>()),
    )
    ..registerFactory<SubscriptionCubit>(
      () => SubscriptionCubit(
        getSubscriptionStatusUseCase: sl<GetSubscriptionStatusUseCase>(),
        getSubscriptionOfferingUseCase: sl<GetSubscriptionOfferingUseCase>(),
        purchaseSubscriptionUseCase: sl<PurchaseSubscriptionUseCase>(),
        restorePurchasesUseCase: sl<RestorePurchasesUseCase>(),
      ),
    );
}
