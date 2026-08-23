import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/tracker_category_model.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class DailyTrackerRemoteDataSource {
  Future<DailyLogModel?> getLogByDate(String dateKey);

  Future<DailyLogModel> initializeLog(String dateKey);

  Future<DailyLogModel> updateCategoryProgress({
    required String dateKey,
    required String categoryId,
    required int delta,
  });

  Future<DailyLogModel> resetLog(String dateKey);
}

class SupabaseDailyTrackerRemoteDataSource
    implements DailyTrackerRemoteDataSource {
  SupabaseDailyTrackerRemoteDataSource({
    required supabase.SupabaseClient client,
    required supabase.GoTrueClient auth,
    required AppLogger logger,
  })  : _client = client,
        _auth = auth,
        _logger = logger;

  final supabase.SupabaseClient _client;
  final supabase.GoTrueClient _auth;
  final AppLogger _logger;

  static const List<TrackerCategoryModel> _fallbackCategories =
      <TrackerCategoryModel>[
        TrackerCategoryModel(
          id: 'beans',
          title: 'Beans / Legumes',
          description: 'Track servings of beans and legumes',
          targetCount: 3,
          displayOrder: 1,
          iconKey: 'beans',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'berries',
          title: 'Berries',
          description: 'Track servings of berries',
          targetCount: 1,
          displayOrder: 2,
          iconKey: 'berries',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'fruits',
          title: 'Fruits',
          description: 'Track fruit servings',
          targetCount: 3,
          displayOrder: 3,
          iconKey: 'fruits',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'cruciferous_vegetables',
          title: 'Cruciferous Vegetables',
          description: 'Track cruciferous veggie servings',
          targetCount: 1,
          displayOrder: 4,
          iconKey: 'cruciferous_vegetables',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'greens',
          title: 'Greens',
          description: 'Track leafy greens servings',
          targetCount: 2,
          displayOrder: 5,
          iconKey: 'greens',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'other_vegetables',
          title: 'Other Vegetables',
          description: 'Track other vegetable servings',
          targetCount: 2,
          displayOrder: 6,
          iconKey: 'other_vegetables',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'flaxseeds',
          title: 'Flaxseeds',
          description: 'Track flaxseed servings',
          targetCount: 1,
          displayOrder: 7,
          iconKey: 'flaxseeds',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'nuts',
          title: 'Nuts',
          description: 'Track nuts servings',
          targetCount: 1,
          displayOrder: 8,
          iconKey: 'nuts',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'spices',
          title: 'Spices',
          description: 'Track turmeric/spice servings',
          targetCount: 1,
          displayOrder: 9,
          iconKey: 'spices',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'whole_grains',
          title: 'Whole Grains',
          description: 'Track whole grain servings',
          targetCount: 3,
          displayOrder: 10,
          iconKey: 'whole_grains',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'beverages',
          title: 'Beverages',
          description: 'Track healthy beverage goals',
          targetCount: 5,
          displayOrder: 11,
          iconKey: 'beverages',
          isActive: true,
        ),
        TrackerCategoryModel(
          id: 'exercise',
          title: 'Exercise',
          description: 'Track exercise sessions',
          targetCount: 1,
          displayOrder: 12,
          iconKey: 'exercise',
          isActive: true,
        ),
      ];

  @override
  Future<DailyLogModel?> getLogByDate(String dateKey) async {
    return _loadLogForUser(userId: _requireUserId(), dateKey: dateKey);
  }

  @override
  Future<DailyLogModel> initializeLog(String dateKey) async {
    final String userId = _requireUserId();
    final DailyLogModel? existing = await _loadLogForUser(
      userId: userId,
      dateKey: dateKey,
    );
    // An existing log with zero items means a previous init failed between the
    // log insert and the item insert — fall through and heal it.
    if (existing != null && existing.items.isNotEmpty) {
      return existing;
    }

    final List<TrackerCategoryModel> categories = await _loadCategories();
    final DateTime now = DateTime.now().toUtc();
    final List<DailyLogItemModel> items = categories
        .map(
          (TrackerCategoryModel category) => DailyLogItemModel(
            id: '', // assigned by the database
            category: category,
            completedCount: 0,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    final DailyLogModel log = _recalculateLog(
      DailyLogModel(
        id: existing?.id ?? '',
        userId: userId,
        logDate: DateTime.parse('${dateKey}T00:00:00Z'),
        items: items,
        totalCompleted: 0,
        totalTarget: items.fold(
          0,
          (int sum, DailyLogItem item) => sum + item.targetCount,
        ),
        completionPercentage: 0,
        isFullyCompleted: false,
      ),
    );

    // Ensure the log row exists; a concurrent init just keeps the winner.
    await _client.from(SupabaseTables.dailyLogs).upsert(
          log.toCreateData(),
          onConflict: 'user_id,log_date',
          ignoreDuplicates: true,
        );
    final Map<String, dynamic> logRow = await _client
        .from(SupabaseTables.dailyLogs)
        .select('id')
        .eq('user_id', userId)
        .eq('log_date', dateKey)
        .single();
    final String logId = logRow['id'] as String;

    // One bulk insert for all category items; duplicates from races or a
    // previous partial init are skipped by the (log_id, category_id) key.
    await _client.from(SupabaseTables.dailyLogItems).upsert(
          items
              .map(
                (DailyLogItemModel item) => item.toCreateData(logId: logId),
              )
              .toList(growable: false),
          onConflict: 'log_id,category_id',
          ignoreDuplicates: true,
        );

    _logger.info(
      'Initialized daily log',
      data: <String, Object?>{'userId': userId, 'dateKey': dateKey},
    );

    // Reload so items carry their database-assigned ids.
    return (await _loadLogForUser(userId: userId, dateKey: dateKey))!;
  }

  @override
  Future<DailyLogModel> updateCategoryProgress({
    required String dateKey,
    required String categoryId,
    required int delta,
  }) async {
    final DailyLogModel current = await initializeLog(dateKey);
    final List<DailyLogItemModel> updatedItems = current.items
        .map((DailyLogItem item) {
          final DailyLogItemModel model = DailyLogItemModel.fromEntity(item);
          if (item.categoryId != categoryId) {
            return model;
          }
          final int nextCompleted = (item.completedCount + delta).clamp(
            0,
            item.targetCount,
          );
          return model.copyWith(
            completedCount: nextCompleted,
            updatedAt: DateTime.now().toUtc(),
          );
        })
        .toList(growable: false);

    final DailyLogItemModel updatedItem = updatedItems.firstWhere(
      (DailyLogItemModel item) => item.categoryId == categoryId,
    );
    // Absolute write (not an increment): the cubit serializes taps, and the
    // clamped read-modify-write above is the source of truth.
    await _client
        .from(SupabaseTables.dailyLogItems)
        .update(updatedItem.toUpdateData())
        .eq('id', updatedItem.id);

    return _saveRecalculatedLog(current.copyWith(items: updatedItems));
  }

  @override
  Future<DailyLogModel> resetLog(String dateKey) async {
    final DailyLogModel current = await initializeLog(dateKey);
    final List<DailyLogItemModel> resetItems = current.items
        .map(
          (DailyLogItem item) => DailyLogItemModel.fromEntity(
            item,
          ).copyWith(completedCount: 0, updatedAt: DateTime.now().toUtc()),
        )
        .toList(growable: false);

    // One bulk reset instead of a per-item loop.
    await _client
        .from(SupabaseTables.dailyLogItems)
        .update(<String, dynamic>{
          'completed_count': 0,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('log_id', current.id);

    return _saveRecalculatedLog(current.copyWith(items: resetItems));
  }

  Future<DailyLogModel?> _loadLogForUser({
    required String userId,
    required String dateKey,
  }) async {
    final Map<String, dynamic>? row = await _client
        .from(SupabaseTables.dailyLogs)
        .select('*, ${SupabaseTables.dailyLogItems}(*)')
        .eq('user_id', userId)
        .eq('log_date', dateKey)
        .maybeSingle();
    if (row == null) {
      return null;
    }

    final List<DailyLogItemModel> items = _sortItems(
      ((row[SupabaseTables.dailyLogItems] as List<dynamic>?) ??
              const <dynamic>[])
          .map(
            (dynamic itemRow) =>
                DailyLogItemModel.fromRow(itemRow as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return _recalculateLog(DailyLogModel.fromRow(row: row, items: items));
  }

  List<DailyLogItemModel> _sortItems(List<DailyLogItemModel> items) {
    items.sort(
      (DailyLogItemModel a, DailyLogItemModel b) =>
          a.category.displayOrder.compareTo(b.category.displayOrder),
    );
    return items;
  }

  Future<List<TrackerCategoryModel>> _loadCategories() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from(SupabaseTables.categoryDefinitions)
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);
      if (rows.isEmpty) {
        return _fallbackCategories;
      }
      return rows
          .map(TrackerCategoryModel.fromRow)
          .toList(growable: false);
    } on Exception catch (exception) {
      _logger.warning(
        'Falling back to bundled category definitions',
        data: <String, Object?>{'reason': exception.toString()},
      );
      return _fallbackCategories;
    }
  }

  Future<DailyLogModel> _saveRecalculatedLog(DailyLogModel log) async {
    final DailyLogModel updatedLog = _recalculateLog(log);
    await _client
        .from(SupabaseTables.dailyLogs)
        .update(updatedLog.toUpdateData())
        .eq('id', updatedLog.id);
    return updatedLog;
  }

  DailyLogModel _recalculateLog(DailyLogModel log) {
    final int totalCompleted = log.items.fold(
      0,
      (int value, DailyLogItem item) => value + item.completedCount,
    );
    final int totalTarget = log.items.fold(
      0,
      (int value, DailyLogItem item) => value + item.targetCount,
    );
    final double completionPercentage = totalTarget == 0
        ? 0
        : (totalCompleted / totalTarget) * 100;

    return log.copyWith(
      totalCompleted: totalCompleted,
      totalTarget: totalTarget,
      completionPercentage: completionPercentage,
      isFullyCompleted: totalCompleted >= totalTarget && totalTarget > 0,
    );
  }

  String _requireUserId() {
    final String? userId = _auth.currentUser?.id;
    if (userId == null) {
      throw const supabase.AuthException(
        'No active session.',
        statusCode: '401',
      );
    }
    return userId;
  }
}
