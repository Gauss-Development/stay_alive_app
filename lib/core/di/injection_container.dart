import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/logger/logger_service.dart';
import 'package:stay_alive/core/network/network_service.dart';
import 'package:stay_alive/core/services/appwrite_client_provider.dart';
import 'package:stay_alive/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:stay_alive/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_oauth_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/logout_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/daily_tracker/data/datasources/daily_tracker_local_data_source.dart';
import 'package:stay_alive/features/daily_tracker/data/repositories_impl/daily_tracker_repository_impl.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/decrement_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_completion_summary_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/increment_category_progress_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/initialize_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/reset_today_log_usecase.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/analytics/data/repositories_impl/in_memory_analytics_repository.dart';
import 'package:stay_alive/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:stay_alive/features/analytics/domain/usecases/track_event_usecase.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/history/domain/repositories/history_repository.dart';
import 'package:stay_alive/features/history/domain/usecases/get_history_summary_usecase.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/history/data/repositories_impl/in_memory_history_repository.dart';
import 'package:stay_alive/features/user/domain/repositories/user_repository.dart';
import 'package:stay_alive/features/user/data/repositories_impl/in_memory_user_repository.dart';
import 'package:stay_alive/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  _registerCore();
  _registerAuthFeature();
  _registerDailyTrackerFeature();
  _registerUserFeature();
  _registerHistoryFeature();
  _registerAnalyticsFeature();
}

void _registerCore() {
  sl
    ..registerLazySingleton<EnvConfig>(EnvConfig.fromEnvironment)
    ..registerLazySingleton<AppLogger>(() => const LoggerService())
    ..registerLazySingleton<NetworkService>(() => const DefaultNetworkService())
    ..registerLazySingleton<Client>(
      () => AppwriteClientProvider(sl<EnvConfig>()).build(),
    )
    ..registerLazySingleton<Account>(() => Account(sl<Client>()));
}

void _registerAuthFeature() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AppwriteAuthRemoteDataSource(
        account: sl<Account>(),
        logger: sl<AppLogger>(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl<AuthRemoteDataSource>(),
        sl<AppLogger>(),
      ),
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
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        loginWithEmailUseCase: sl<LoginWithEmailUseCase>(),
        signUpWithEmailUseCase: sl<SignUpWithEmailUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        loginWithOAuthUseCase: sl<LoginWithOAuthUseCase>(),
        completeOnboardingUseCase: sl<CompleteOnboardingUseCase>(),
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
    ..registerLazySingleton<DailyTrackerLocalDataSource>(
      () => InMemoryDailyTrackerLocalDataSource(sl<AppLogger>()),
    )
    ..registerLazySingleton<DailyTrackerRepository>(
      () => DailyTrackerRepositoryImpl(sl<DailyTrackerLocalDataSource>()),
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
        incrementCategoryProgressUseCase: sl<IncrementCategoryProgressUseCase>(),
        decrementCategoryProgressUseCase: sl<DecrementCategoryProgressUseCase>(),
        resetTodayLogUseCase: sl<ResetTodayLogUseCase>(),
        getCompletionSummaryUseCase: sl<GetCompletionSummaryUseCase>(),
        logger: sl<AppLogger>(),
      ),
    );
}

void _registerUserFeature() {
  sl
    ..registerLazySingleton<UserRepository>(
      InMemoryUserRepository.new,
    )
    ..registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(sl<UserRepository>()),
    )
    ..registerFactory<UserProfileCubit>(
      () => UserProfileCubit(sl<GetUserProfileUseCase>()),
    );
}

void _registerHistoryFeature() {
  sl
    ..registerLazySingleton<HistoryRepository>(
      InMemoryHistoryRepository.new,
    )
    ..registerLazySingleton<GetHistorySummaryUseCase>(
      () => GetHistorySummaryUseCase(sl<HistoryRepository>()),
    )
    ..registerFactory<HistoryCubit>(
      () => HistoryCubit(sl<GetHistorySummaryUseCase>()),
    );
}

void _registerAnalyticsFeature() {
  sl
    ..registerLazySingleton<AnalyticsRepository>(
      InMemoryAnalyticsRepository.new,
    )
    ..registerLazySingleton<TrackEventUseCase>(
      () => TrackEventUseCase(sl<AnalyticsRepository>()),
    )
    ..registerFactory<AnalyticsCubit>(
      () => AnalyticsCubit(sl<TrackEventUseCase>()),
    );
}
