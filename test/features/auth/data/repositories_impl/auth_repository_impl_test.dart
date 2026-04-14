import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:stay_alive/features/auth/data/models/auth_session_model.dart';
import 'package:stay_alive/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  late _MockAuthRemoteDataSource remoteDataSource;
  late _MockAppLogger logger;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _MockAuthRemoteDataSource();
    logger = _MockAppLogger();
    repository = AuthRepositoryImpl(remoteDataSource, logger);

    when(
      () => logger.error(
        any(),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
        data: any(named: 'data'),
      ),
    ).thenReturn(null);
  });

  test('loginWithEmail returns session when datasource succeeds', () async {
    final AuthSessionModel session = AuthSessionModel(
      id: 'session_1',
      userId: 'user_1',
      provider: 'email',
      expire: DateTime.parse('2030-01-01T00:00:00Z'),
    );

    when(
      () => remoteDataSource.loginWithEmail(
        email: 'user@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => session);

    final Result<AuthSession> result = await repository.loginWithEmail(
      email: 'user@example.com',
      password: 'password123',
    );

    expect(result, Right<Failure, AuthSession>(session));
  });

  test('checkSession returns AuthFailure when no active session exists', () async {
    when(() => remoteDataSource.getCurrentSession()).thenAnswer((_) async => null);

    final Result<AuthSession> result = await repository.checkSession();

    expect(result.isLeft(), isTrue);
    final Failure failure = result.fold((Failure value) => value, (_) {
      return const UnknownFailure('expected left');
    });
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'No active session found.');
  });

  test('getCurrentUser maps datasource exception to failure', () async {
    when(() => remoteDataSource.getCurrentUser()).thenThrow(Exception('boom'));

    final Result<AuthUser> result = await repository.getCurrentUser();

    expect(result.isLeft(), isTrue);
    final Failure failure = result.fold((Failure value) => value, (_) {
      return const UnknownFailure('expected left');
    });
    expect(failure, isA<UnknownFailure>());
  });
}
