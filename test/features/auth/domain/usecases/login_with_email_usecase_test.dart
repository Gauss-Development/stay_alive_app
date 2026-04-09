import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/usecases/login_with_email_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginWithEmailUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginWithEmailUseCase(repository);
  });

  const params = LoginWithEmailParams(
    email: 'user@example.com',
    password: 'password123',
  );
  final expectedSession = AuthSession(
    id: 'session-1',
    userId: 'user-1',
    provider: 'email',
    expire: DateTime.parse('2030-01-01T00:00:00Z'),
  );

  test('returns session on successful login', () async {
    when(
      () => repository.loginWithEmail(
        email: params.email,
        password: params.password,
      ),
    ).thenAnswer((_) async => Right<Failure, AuthSession>(expectedSession));

    final result = await useCase(params);

    expect(result, Right<Failure, AuthSession>(expectedSession));
    verify(
      () => repository.loginWithEmail(
        email: params.email,
        password: params.password,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns failure when login fails', () async {
    const failure = AuthFailure('Invalid credentials.');
    when(
      () => repository.loginWithEmail(
        email: params.email,
        password: params.password,
      ),
    ).thenAnswer((_) async => const Left<Failure, AuthSession>(failure));

    final result = await useCase(params);

    expect(result, const Left<Failure, AuthSession>(failure));
    verify(
      () => repository.loginWithEmail(
        email: params.email,
        password: params.password,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
