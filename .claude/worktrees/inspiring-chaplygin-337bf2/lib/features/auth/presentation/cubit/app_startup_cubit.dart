import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:stay_alive/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_state.dart';

class AppStartupCubit extends Cubit<AppStartupState> {
  AppStartupCubit({
    required CheckSessionUseCase checkSessionUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AppLogger logger,
  })  : _checkSessionUseCase = checkSessionUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logger = logger,
        super(const AppStartupState.initial());

  final CheckSessionUseCase _checkSessionUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AppLogger _logger;

  Future<void> initialize() async {
    emit(const AppStartupState.loading());

    final sessionResult = await _checkSessionUseCase(const NoParams());

    await sessionResult.fold(
      (failure) async {
        _logger.warning(
          'No active session on app startup',
          data: <String, Object?>{'reason': failure.message},
        );
        emit(const AppStartupState.unauthenticated());
      },
      (session) async {
        _logger.info(
          'Active session found on startup',
          data: <String, Object?>{'sessionId': session.id},
        );
        final userResult = await _getCurrentUserUseCase(const NoParams());
        userResult.fold(
          (failure) {
            _logger.error(
              'Failed to fetch user after session recovery',
              data: <String, Object?>{'reason': failure.message},
            );
            emit(const AppStartupState.unauthenticated());
          },
          (user) {
            if (user.onboardingCompleted) {
              emit(AppStartupState.authenticated(user));
            } else {
              emit(AppStartupState.onboardingRequired(user));
            }
          },
        );
      },
    );
  }
}
