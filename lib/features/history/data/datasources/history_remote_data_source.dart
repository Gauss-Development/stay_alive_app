import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class HistoryRemoteDataSource {
  Future<List<DailyLogModel>> fetchLogs({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class SupabaseHistoryRemoteDataSource implements HistoryRemoteDataSource {
  SupabaseHistoryRemoteDataSource({
    required supabase.SupabaseClient client,
    required supabase.GoTrueClient auth,
  })  : _client = client,
        _auth = auth;

  final supabase.SupabaseClient _client;
  final supabase.GoTrueClient _auth;

  @override
  Future<List<DailyLogModel>> fetchLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final String? userId = _auth.currentUser?.id;
    if (userId == null) {
      throw const supabase.AuthException(
        'No active session.',
        statusCode: '401',
      );
    }

    final List<Map<String, dynamic>> rows = await _client
        .from(SupabaseTables.dailyLogs)
        .select()
        .eq('user_id', userId)
        .gte('log_date', _dateKey(startDate))
        .lte('log_date', _dateKey(endDate))
        .order('log_date', ascending: true)
        .limit(100);

    return rows
        .map(
          (Map<String, dynamic> row) => DailyLogModel.fromRow(
            row: row,
            items: const <DailyLogItemModel>[],
          ),
        )
        .toList(growable: false);
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
