import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:stay_alive/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._logger,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AppLogger _logger;

  @override
  Future<Result<AuthSession>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthSession session = await _remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      return Right<Failure, AuthSession>(session);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to login with email.',
        error: exception,
        stackTrace: stackTrace,
        data: <String, Object?>{'email': email},
      );
      return Left<Failure, AuthSession>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final AuthUser user = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return Right<Failure, AuthUser>(user);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to sign up with email.',
        error: exception,
        stackTrace: stackTrace,
        data: <String, Object?>{'email': email},
      );
      return Left<Failure, AuthUser>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<AuthSession>> loginWithOAuth({
    required OAuthSignInProvider provider,
  }) async {
    try {
      final AuthSession session = await _remoteDataSource.loginWithOAuth(
        provider: _mapProvider(provider),
      );
      return Right<Failure, AuthSession>(session);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to login with OAuth.',
        error: exception,
        stackTrace: stackTrace,
        data: <String, Object?>{'provider': provider.name},
      );
      return Left<Failure, AuthSession>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<AuthUser>> getCurrentUser() async {
    try {
      final AuthUser user = await _remoteDataSource.getCurrentUser();
      return Right<Failure, AuthUser>(user);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to load current user.',
        error: exception,
        stackTrace: stackTrace,
      );
      return Left<Failure, AuthUser>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<AuthSession>> checkSession() async {
    try {
      final AuthSession? session = await _remoteDataSource.getCurrentSession();
      if (session == null) {
        return const Left<Failure, AuthSession>(
          AuthFailure('No active session found.'),
        );
      }
      return Right<Failure, AuthSession>(session);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to check session.',
        error: exception,
        stackTrace: stackTrace,
      );
      return Left<Failure, AuthSession>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right<Failure, void>(null);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to logout.',
        error: exception,
        stackTrace: stackTrace,
      );
      return Left<Failure, void>(mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<AuthUser>> markOnboardingCompleted() async {
    try {
      final AuthUser user = await _remoteDataSource.updatePreferences(
        preferences: <String, dynamic>{'onboardingCompleted': true},
      );
      return Right<Failure, AuthUser>(user);
    } catch (exception, stackTrace) {
      _logger.error(
        'Failed to mark onboarding completed.',
        error: exception,
        stackTrace: stackTrace,
      );
      return Left<Failure, AuthUser>(mapExceptionToFailure(exception));
    }
  }

  appwrite_enums.OAuthProvider _mapProvider(OAuthSignInProvider provider) {
    switch (provider) {
      case OAuthSignInProvider.google:
        return appwrite_enums.OAuthProvider.google;
      case OAuthSignInProvider.apple:
        return appwrite_enums.OAuthProvider.apple;
    }
  }
}
