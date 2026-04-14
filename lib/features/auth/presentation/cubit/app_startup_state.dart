import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';

enum StartupStatus {
  initial,
  loading,
  ready,
  error,
}

enum StartupDestination {
  none,
  login,
  onboarding,
  home,
}

class AppStartupState extends Equatable {
  const AppStartupState({
    required this.status,
    required this.destination,
    this.user,
    this.message,
  });

  const AppStartupState.initial()
      : status = StartupStatus.initial,
        destination = StartupDestination.none,
        user = null,
        message = null;

  const AppStartupState.loading()
      : status = StartupStatus.loading,
        destination = StartupDestination.none,
        user = null,
        message = null;

  const AppStartupState.ready({
    required StartupDestination destination,
    AuthUser? user,
  })  : status = StartupStatus.ready,
        destination = destination,
        user = user,
        message = null;

  const AppStartupState.unauthenticated()
      : status = StartupStatus.ready,
        destination = StartupDestination.login,
        user = null,
        message = null;

  const AppStartupState.onboardingRequired(AuthUser currentUser)
      : status = StartupStatus.ready,
        destination = StartupDestination.onboarding,
        user = currentUser,
        message = null;

  const AppStartupState.authenticated(AuthUser currentUser)
      : status = StartupStatus.ready,
        destination = StartupDestination.home,
        user = currentUser,
        message = null;

  const AppStartupState.error(String this.message)
      : status = StartupStatus.error,
        destination = StartupDestination.none,
        user = null;

  final StartupStatus status;
  final StartupDestination destination;
  final AuthUser? user;
  final String? message;

  @override
  List<Object?> get props => <Object?>[status, destination, user, message];
}
