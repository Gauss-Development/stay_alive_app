import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/auth/data/datasources/auth_remote_data_source.dart';

class _MockAccount extends Mock implements Account {}

class _MockDatabases extends Mock implements Databases {}

class _MockFunctions extends Mock implements Functions {}

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

EnvConfig _env({String deleteUserFunctionId = 'delete_user'}) => EnvConfig(
  appFlavor: AppFlavor.development,
  appwriteEndpoint: '',
  appwriteProjectId: '',
  appwriteDatabaseId: 'db',
  usersCollectionId: 'users',
  categoryDefinitionsCollectionId: 'categories',
  dailyLogsCollectionId: 'daily_logs',
  dailyLogItemsCollectionId: 'daily_log_items',
  subscriptionsCollectionId: 'subscriptions',
  analyticsEventsCollectionId: 'analytics_events',
  gamificationProfilesCollectionId: 'gamification_profiles',
  gamificationEventsCollectionId: 'gamification_events',
  deleteUserFunctionId: deleteUserFunctionId,
  aiCoachFunctionId: '',
  widgetAppGroupId: '',
  revenueCatAndroidApiKey: '',
  revenueCatIosApiKey: '',
  revenueCatEntitlementId: 'premium',
  revenueCatOfferingId: 'default',
  allowSelfSigned: false,
  sentryDsn: '',
  sentryEnvironment: 'test',
);

appwrite_models.Document _doc(String id) => appwrite_models.Document(
  $id: id,
  $sequence: 0,
  $collectionId: 'c',
  $databaseId: 'db',
  $createdAt: '2026-06-01T00:00:00.000Z',
  $updatedAt: '2026-06-01T00:00:00.000Z',
  $permissions: const <String>[],
  data: const <String, dynamic>{},
);

appwrite_models.Execution _execution({
  String status = 'completed',
  int code = 200,
}) => appwrite_models.Execution(
  $id: 'exec_1',
  $createdAt: '2026-06-01T00:00:00.000Z',
  $updatedAt: '2026-06-01T00:00:00.000Z',
  $permissions: const <String>[],
  functionId: 'delete_user',
  trigger: 'http',
  status: status,
  requestMethod: 'POST',
  requestPath: '/',
  requestHeaders: const <appwrite_models.Headers>[],
  responseStatusCode: code,
  responseBody: '',
  responseHeaders: const <appwrite_models.Headers>[],
  logs: '',
  errors: '',
  duration: 0.1,
);

void main() {
  late _MockAccount account;
  late _MockDatabases databases;
  late _MockFunctions functions;
  late _RecordingLogger logger;

  setUp(() {
    account = _MockAccount();
    databases = _MockDatabases();
    functions = _MockFunctions();
    logger = _RecordingLogger();

    when(() => account.get()).thenAnswer(
      (_) async => appwrite_models.User(
        $id: 'user_1',
        $createdAt: '2026-01-01T00:00:00.000Z',
        $updatedAt: '2026-01-01T00:00:00.000Z',
        name: 'Test',
        registration: '2026-01-01T00:00:00.000Z',
        status: true,
        labels: const <String>[],
        passwordUpdate: '',
        email: 't@example.com',
        phone: '',
        emailVerification: true,
        phoneVerification: false,
        mfa: false,
        prefs: appwrite_models.Preferences(data: const <String, dynamic>{}),
        targets: const <appwrite_models.Target>[],
        accessedAt: '2026-01-01T00:00:00.000Z',
      ),
    );
    when(() => account.deleteSessions()).thenAnswer((_) async {});
  });

  AppwriteAuthRemoteDataSource build({String functionId = 'delete_user'}) {
    return AppwriteAuthRemoteDataSource(
      account: account,
      databases: databases,
      functions: functions,
      envConfig: _env(deleteUserFunctionId: functionId),
      logger: logger,
    );
  }

  void stubEmptyCollections() {
    when(
      () => databases.listDocuments(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        queries: any(named: 'queries'),
      ),
    ).thenAnswer(
      (_) async => appwrite_models.DocumentList(
        total: 0,
        documents: const <appwrite_models.Document>[],
      ),
    );
    when(
      () => databases.deleteDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
      ),
    ).thenAnswer((_) async {});
  }

  test('terminates when documents are listable but never deletable', () async {
    // Reproduces the hang: gamification events were created read-only, so they
    // list forever while every delete is refused. Appwrite masks the permission
    // failure as 404, which the data source swallows.
    when(
      () => databases.listDocuments(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        queries: any(named: 'queries'),
      ),
    ).thenAnswer(
      (_) async => appwrite_models.DocumentList(
        total: 2,
        documents: <appwrite_models.Document>[_doc('stuck_1'), _doc('stuck_2')],
      ),
    );
    when(
      () => databases.deleteDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
      ),
    ).thenThrow(AppwriteException('not found', 404));
    when(
      () => functions.createExecution(
        functionId: any(named: 'functionId'),
        xasync: any(named: 'xasync'),
      ),
    ).thenAnswer((_) async => _execution());

    // Fails by timing out rather than asserting if the guard is removed.
    await build().deleteAccount().timeout(const Duration(seconds: 5));

    expect(
      logger.errors.any((String m) => m.contains('made no progress')),
      isTrue,
      reason: 'orphaned documents must be logged for server-side cleanup',
    );
  });

  test('runs the server-side function to delete the auth record', () async {
    stubEmptyCollections();
    when(
      () => functions.createExecution(
        functionId: any(named: 'functionId'),
        xasync: any(named: 'xasync'),
      ),
    ).thenAnswer((_) async => _execution());

    await build().deleteAccount();

    verify(
      () => functions.createExecution(functionId: 'delete_user', xasync: false),
    ).called(1);
    verify(() => account.deleteSessions()).called(1);
  });

  test('warns but does not throw when the function id is unset', () async {
    stubEmptyCollections();

    await build(functionId: '').deleteAccount();

    verifyNever(
      () => functions.createExecution(
        functionId: any(named: 'functionId'),
        xasync: any(named: 'xasync'),
      ),
    );
    expect(
      logger.warnings.any((String m) => m.contains('auth record NOT deleted')),
      isTrue,
    );
    // Still signs the user out — their documents are already gone.
    verify(() => account.deleteSessions()).called(1);
  });

  test('does not throw when the auth-record deletion fails', () async {
    stubEmptyCollections();
    when(
      () => functions.createExecution(
        functionId: any(named: 'functionId'),
        xasync: any(named: 'xasync'),
      ),
    ).thenAnswer((_) async => _execution(status: 'failed', code: 500));

    await build().deleteAccount();

    expect(
      logger.errors.any((String m) => m.contains('may be orphaned')),
      isTrue,
    );
    verify(() => account.deleteSessions()).called(1);
  });

  test('tolerates a 401 when clearing sessions', () async {
    // The server function may already have removed the auth record and its
    // sessions, so the client-side cleanup is expected to be unauthorized.
    stubEmptyCollections();
    when(
      () => functions.createExecution(
        functionId: any(named: 'functionId'),
        xasync: any(named: 'xasync'),
      ),
    ).thenAnswer((_) async => _execution());
    when(
      () => account.deleteSessions(),
    ).thenThrow(AppwriteException('unauthorized', 401));

    await expectLater(build().deleteAccount(), completes);
  });
}
