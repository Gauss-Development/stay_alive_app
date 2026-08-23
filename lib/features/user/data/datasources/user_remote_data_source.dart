import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/user/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class UserRemoteDataSource {
  Future<UserProfileModel> fetchProfile();
}

class SupabaseUserRemoteDataSource implements UserRemoteDataSource {
  SupabaseUserRemoteDataSource({
    required supabase.SupabaseClient client,
    required supabase.GoTrueClient auth,
    required AppLogger logger,
  })  : _client = client,
        _auth = auth,
        _logger = logger;

  final supabase.SupabaseClient _client;
  final supabase.GoTrueClient _auth;
  final AppLogger _logger;

  @override
  Future<UserProfileModel> fetchProfile() async {
    final supabase.User? user = _auth.currentUser;
    if (user == null) {
      throw const supabase.AuthException(
        'No active session.',
        statusCode: '401',
      );
    }
    _logger.debug(
      'Fetching user profile row',
      data: <String, Object?>{'userId': user.id},
    );

    // `.single()` throws (PGRST116) when the row is missing — the same
    // failure surface as the old getDocument 404.
    final Map<String, dynamic> row = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', user.id)
        .single();

    return UserProfileModel.fromRow(row);
  }
}
