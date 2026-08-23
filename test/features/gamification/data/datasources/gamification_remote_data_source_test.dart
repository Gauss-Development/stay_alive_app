import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stay_alive/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_overview_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

final User _user = User(
  id: 'user-1',
  appMetadata: const <String, dynamic>{},
  userMetadata: const <String, dynamic>{},
  aud: 'authenticated',
  createdAt: DateTime.utc(2026).toIso8601String(),
);

/// Runs the datasource against a canned PostgREST so tests can assert on the
/// actual requests (paths, filters, headers) the Supabase client emits.
class _FakePostgrest {
  final List<http.Request> requests = <http.Request>[];

  late final SupabaseClient client = SupabaseClient(
    'http://localhost:54321',
    'test-key',
    httpClient: MockClient(_handle),
  );

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final String path = request.url.path;
    final bool wantsSingleObject =
        request.headers['Accept']?.contains('vnd.pgrst.object') ?? false;

    if (path.endsWith('/gamification_profiles')) {
      if (request.method == 'GET') {
        // No persisted profile yet: PostgREST answers a single-object request
        // with PGRST116, which maybeSingle() converts to null.
        if (wantsSingleObject) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'code': 'PGRST116',
              'message': 'JSON object requested, multiple (or no) rows',
              'details': 'The result contains 0 rows',
              'hint': null,
            }),
            406,
            headers: <String, String>{'Content-Type': 'application/json'},
            request: request,
          );
        }
        return _jsonList(request, const <Map<String, dynamic>>[]);
      }
      return http.Response('', 201, request: request);
    }

    if (path.endsWith('/daily_logs')) {
      return _jsonList(request, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'log-1',
          'user_id': 'user-1',
          'log_date': '2026-08-20',
          'total_completed': 3,
          'total_target': 24,
          'completion_percentage': 12.5,
          'is_fully_completed': false,
          'created_at': '2026-08-20T00:00:00Z',
          'updated_at': '2026-08-20T10:00:00Z',
          'daily_log_items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'item-1',
              'log_id': 'log-1',
              'user_id': 'user-1',
              'category_id': 'beans',
              'category_title': 'Beans / Legumes',
              'target_count': 3,
              'display_order': 1,
              'icon_key': 'beans',
              'is_active': true,
              'completed_count': 3,
              'created_at': '2026-08-20T00:00:00Z',
              'updated_at': '2026-08-20T10:00:00Z',
            },
          ],
        },
      ]);
    }

    if (path.endsWith('/gamification_events')) {
      if (request.method == 'GET') {
        return _jsonList(request, const <Map<String, dynamic>>[]);
      }
      return http.Response('', 201, request: request);
    }

    fail('Unexpected request: ${request.method} ${request.url}');
  }

  http.Response _jsonList(http.Request request, List<Map<String, dynamic>> rows) {
    return http.Response(
      jsonEncode(rows),
      200,
      headers: <String, String>{'Content-Type': 'application/json'},
      request: request,
    );
  }

  Iterable<http.Request> to(String table, {String? method}) => requests.where(
        (http.Request request) =>
            request.url.path.endsWith('/$table') &&
            (method == null || request.method == method),
      );
}

void main() {
  late _FakePostgrest postgrest;
  late _MockGoTrueClient auth;
  late SupabaseGamificationRemoteDataSource dataSource;

  setUp(() {
    postgrest = _FakePostgrest();
    auth = _MockGoTrueClient();
    when(() => auth.currentUser).thenReturn(_user);
    dataSource = SupabaseGamificationRemoteDataSource(
      client: postgrest.client,
      auth: auth,
    );
  });

  test('loads logs with embedded items in one filtered request', () async {
    final GamificationOverviewModel overview =
        await dataSource.reconcileOverview(isPremium: false);

    final http.Request logsRequest = postgrest.to('daily_logs').single;
    final String query = Uri.decodeComponent(logsRequest.url.query);
    // Embedded select replaces the old two-phase load: one request, filtered
    // by owner and date window, items included.
    expect(query, contains('select=*,daily_log_items(*)'));
    expect(query, contains('user_id=eq.user-1'));
    expect(query, contains('log_date=gte.'));
    expect(postgrest.to('daily_log_items'), isEmpty);

    expect(overview.profile.totalCategoriesCompleted, greaterThan(0));
  });

  test('recent XP events are ordered by server insert time', () async {
    await dataSource.reconcileOverview(isPremium: false);

    final http.Request eventsRequest =
        postgrest.to('gamification_events', method: 'GET').first;
    final String query = Uri.decodeComponent(eventsRequest.url.query);
    // `created_at` is client-set and backdated for badge events; ordering must
    // use the server-side `inserted_at` for parity with Appwrite `$createdAt`.
    expect(query, contains('order=inserted_at.desc'));
    expect(query, contains('limit=50'));
    expect(query, contains('user_id=eq.user-1'));
  });

  test('profile is upserted onto the user_id key in one request', () async {
    await dataSource.reconcileOverview(isPremium: false);

    final http.Request upsert =
        postgrest.to('gamification_profiles', method: 'POST').single;
    expect(
      Uri.decodeComponent(upsert.url.query),
      contains('on_conflict=user_id'),
    );
    expect(upsert.headers['Prefer'], contains('resolution=merge-duplicates'));

    final Map<String, dynamic> payload =
        jsonDecode(upsert.body) as Map<String, dynamic>;
    expect(payload['user_id'], 'user-1');
    // created_at is never sent: the column default stamps it on insert and an
    // upsert must not overwrite it on update.
    expect(payload.containsKey('created_at'), isFalse);
  });
}
