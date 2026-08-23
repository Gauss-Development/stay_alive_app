import 'dart:convert';

import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AnalyticsRemoteDataSource {
  Future<void> trackEvent(AnalyticsEvent event);
}

class SupabaseAnalyticsRemoteDataSource implements AnalyticsRemoteDataSource {
  SupabaseAnalyticsRemoteDataSource({
    required supabase.SupabaseClient client,
    required supabase.GoTrueClient auth,
  })  : _client = client,
        _auth = auth;

  final supabase.SupabaseClient _client;
  final supabase.GoTrueClient _auth;

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    // Logged-out events insert under the anon RLS policy with a null user_id.
    final String? userId = _auth.currentUser?.id;

    await _client.from(SupabaseTables.analyticsEvents).insert(
      <String, dynamic>{
        'user_id': userId,
        'event_name': event.name,
        'screen_name': event.screenName ?? '',
        'metadata_json': jsonEncode(event.metadata),
        'created_at': event.createdAt.toUtc().toIso8601String(),
      },
    );
  }
}
