import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';

class _MockAccount extends Mock implements Account {}

class _MockDatabases extends Mock implements Databases {}

const String _logsCollection = 'daily_logs';
const String _itemsCollection = 'daily_log_items';
const String _eventsCollection = 'gamification_events';
const String _profilesCollection = 'gamification_profiles';

const EnvConfig _envConfig = EnvConfig(
  appFlavor: AppFlavor.development,
  appwriteEndpoint: '',
  appwriteProjectId: '',
  appwriteDatabaseId: 'db',
  usersCollectionId: 'users',
  categoryDefinitionsCollectionId: 'categories',
  dailyLogsCollectionId: _logsCollection,
  dailyLogItemsCollectionId: _itemsCollection,
  subscriptionsCollectionId: 'subscriptions',
  analyticsEventsCollectionId: 'analytics',
  gamificationProfilesCollectionId: _profilesCollection,
  gamificationEventsCollectionId: _eventsCollection,
  deleteUserFunctionId: '',
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

appwrite_models.Document _document(
  String id,
  Map<String, dynamic> data, {
  String collectionId = _itemsCollection,
}) {
  return appwrite_models.Document(
    $id: id,
    $sequence: 0,
    $collectionId: collectionId,
    $databaseId: 'db',
    $createdAt: '2026-06-01T00:00:00.000Z',
    $updatedAt: '2026-06-01T00:00:00.000Z',
    $permissions: const <String>[],
    data: data,
  );
}

appwrite_models.DocumentList _list(List<appwrite_models.Document> documents) {
  return appwrite_models.DocumentList(
    total: documents.length,
    documents: documents,
  );
}

void main() {
  late _MockAccount account;
  late _MockDatabases databases;
  late AppwriteGamificationRemoteDataSource dataSource;

  /// Every `queries` list the items collection was asked for, in order.
  late List<List<String>> itemQueries;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    account = _MockAccount();
    databases = _MockDatabases();
    itemQueries = <List<String>>[];

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

    // No persisted profile yet.
    when(
      () => databases.getDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
      ),
    ).thenThrow(AppwriteException('not found', 404));

    when(
      () => databases.updateDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => _document('written', <String, dynamic>{}));

    when(
      () => databases.createDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
        permissions: any(named: 'permissions'),
      ),
    ).thenAnswer((_) async => _document('written', <String, dynamic>{}));

    dataSource = AppwriteGamificationRemoteDataSource(
      account: account,
      databases: databases,
      envConfig: _envConfig,
    );
  });

  /// 120 items for one log — more than one page, so a non-paging
  /// implementation returns a truncated set.
  void stubOneLogWith120Items() {
    const String logId = 'user_1_2026-06-01';
    final List<appwrite_models.Document> allItems = List.generate(
      120,
      (int index) => _document('item_$index', <String, dynamic>{
        'log_document_id': logId,
        'category_id': 'greens',
        'completed_count': 1,
      }),
    );

    when(
      () => databases.listDocuments(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        queries: any(named: 'queries'),
      ),
    ).thenAnswer((Invocation invocation) async {
      final String collectionId =
          invocation.namedArguments[#collectionId] as String;
      final List<String> queries =
          (invocation.namedArguments[#queries] as List<String>?) ??
          const <String>[];

      switch (collectionId) {
        case _logsCollection:
          return _list(<appwrite_models.Document>[
            _document(logId, <String, dynamic>{
              'log_date': '2026-06-01',
              'user_id': 'user_1',
            }, collectionId: _logsCollection),
          ]);
        case _itemsCollection:
          itemQueries.add(queries);
          final bool isSecondPage = queries.any(
            (String query) => query.contains('cursorAfter'),
          );
          return _list(
            isSecondPage ? allItems.sublist(100) : allItems.sublist(0, 100),
          );
        default:
          return _list(const <appwrite_models.Document>[]);
      }
    });
  }

  test('filters daily-log items server-side instead of scanning the collection',
      () async {
    stubOneLogWith120Items();

    await dataSource.reconcileOverview(isPremium: false);

    expect(itemQueries, isNotEmpty);
    expect(
      itemQueries.first.any(
        (String query) => query.contains('log_document_id'),
      ),
      isTrue,
      reason: 'items must be filtered by log id, not fetched collection-wide',
    );
  });

  test('pages past the first full page so the newest items are not dropped',
      () async {
    stubOneLogWith120Items();

    await dataSource.reconcileOverview(isPremium: false);

    expect(
      itemQueries.length,
      greaterThanOrEqualTo(2),
      reason: 'a saturated first page must be followed by a cursor request',
    );
    expect(
      itemQueries.last.any((String query) => query.contains('cursorAfter')),
      isTrue,
      reason: 'the follow-up page must continue from the last document',
    );
  });

  test('never issues an unbounded limit that silently truncates', () async {
    stubOneLogWith120Items();

    await dataSource.reconcileOverview(isPremium: false);

    for (final List<String> queries in itemQueries) {
      expect(
        queries.any((String query) => query.contains('5000')),
        isFalse,
        reason: 'limit(5000) drops the newest rows once a user exceeds it',
      );
    }
  });
}
