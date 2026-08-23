import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

/// Records messages so tests can assert on operator-facing diagnostics.
class _RecordingLogger implements AppLogger {
  final List<String> errors = <String>[];
  final List<String> warnings = <String>[];

  @override
  void debug(String message, {Map<String, Object?>? data}) {}

  @override
  void info(String message, {Map<String, Object?>? data}) {}

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) => warnings.add(message);

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) => errors.add(message);
}

final User _user = User(
  id: 'user-1',
  appMetadata: const <String, dynamic>{'provider': 'email'},
  userMetadata: const <String, dynamic>{'name': 'Test User'},
  aud: 'authenticated',
  email: 'user@test.local',
  createdAt: DateTime.utc(2026).toIso8601String(),
);

void main() {
  setUpAll(() {
    registerFallbackValue(SignOutScope.global);
  });

  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;
  late _MockFunctionsClient functions;
  late _RecordingLogger logger;
  late SupabaseAuthRemoteDataSource dataSource;

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    functions = _MockFunctionsClient();
    logger = _RecordingLogger();
    dataSource = SupabaseAuthRemoteDataSource(
      client: client,
      auth: auth,
      functions: functions,
      logger: logger,
    );

    when(() => auth.currentUser).thenReturn(_user);
    when(() => auth.signOut(scope: any(named: 'scope')))
        .thenAnswer((_) async {});
  });

  group('deleteAccount', () {
    test('invokes delete_user and signs out all sessions', () async {
      when(() => functions.invoke(SupabaseFunctions.deleteUser)).thenAnswer(
        (_) async => const FunctionResponse(
          status: 200,
          data: <String, dynamic>{'ok': true},
        ),
      );

      await dataSource.deleteAccount();

      verify(() => functions.invoke(SupabaseFunctions.deleteUser)).called(1);
      verify(() => auth.signOut(scope: SignOutScope.global)).called(1);
      expect(logger.errors, isEmpty);
    });

    test('a failed edge function is logged but never blocks sign-out',
        () async {
      when(() => functions.invoke(SupabaseFunctions.deleteUser)).thenThrow(
        const FunctionException(status: 500, reasonPhrase: 'boom'),
      );

      await dataSource.deleteAccount();

      // The account may be orphaned server-side — that goes to Sentry — but
      // the user must still end up signed out locally.
      expect(logger.errors, hasLength(1));
      verify(() => auth.signOut(scope: SignOutScope.global)).called(1);
    });

    test('sign-out errors after deletion are tolerated', () async {
      when(() => functions.invoke(SupabaseFunctions.deleteUser)).thenAnswer(
        (_) async => const FunctionResponse(
          status: 200,
          data: <String, dynamic>{'ok': true},
        ),
      );
      when(() => auth.signOut(scope: any(named: 'scope')))
          .thenThrow(const AuthException('server error', statusCode: '500'));

      await expectLater(dataSource.deleteAccount(), completes);
      expect(logger.warnings, hasLength(1));
    });

    test('throws when there is no active session', () async {
      when(() => auth.currentUser).thenReturn(null);

      await expectLater(
        dataSource.deleteAccount(),
        throwsA(isA<AuthException>()),
      );
      verifyNever(() => functions.invoke(any()));
    });
  });
}
