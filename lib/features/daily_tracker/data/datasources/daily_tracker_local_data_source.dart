import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/tracker_category_model.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

abstract class DailyTrackerLocalDataSource {
  Future<DailyLogModel?> getLogByDate(String dateKey);

  Future<DailyLogModel> initializeLog(String dateKey);

  Future<DailyLogModel> updateCategoryProgress({
    required String dateKey,
    required String categoryId,
    required int delta,
  });

  Future<DailyLogModel> resetLog(String dateKey);
}

class InMemoryDailyTrackerLocalDataSource implements DailyTrackerLocalDataSource {
  InMemoryDailyTrackerLocalDataSource(this._logger);

  final AppLogger _logger;
  final Map<String, DailyLogModel> _logsByDate = <String, DailyLogModel>{};

  static const List<TrackerCategoryModel> _defaultCategories = <TrackerCategoryModel>[
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
    return _logsByDate[dateKey];
  }

  @override
  Future<DailyLogModel> initializeLog(String dateKey) async {
    final DailyLogModel existing = _logsByDate[dateKey] ?? _buildInitialLog(dateKey);
    _logsByDate[dateKey] = existing;
    return existing;
  }

  @override
  Future<DailyLogModel> updateCategoryProgress({
    required String dateKey,
    required String categoryId,
    required int delta,
  }) async {
    final DailyLogModel current = _logsByDate[dateKey] ?? _buildInitialLog(dateKey);
    final List<DailyLogItem> updatedItems = current.items
        .map((DailyLogItem item) {
          if (item.category.id != categoryId) {
            return item;
          }
          final int nextCompleted = (item.completedCount + delta).clamp(0, item.targetCount);
          return item.copyWith(completedCount: nextCompleted);
        })
        .toList(growable: false);

    final DailyLogModel updatedLog = _recalculateLog(current.copyWith(items: updatedItems));
    _logsByDate[dateKey] = updatedLog;
    _logger.info(
      'Updated category progress',
      data: <String, Object?>{
        'dateKey': dateKey,
        'categoryId': categoryId,
        'delta': delta,
      },
    );
    return updatedLog;
  }

  @override
  Future<DailyLogModel> resetLog(String dateKey) async {
    final DailyLogModel existing = _logsByDate[dateKey] ?? _buildInitialLog(dateKey);
    final List<DailyLogItem> resetItems = existing.items
        .map((DailyLogItem item) => item.copyWith(completedCount: 0))
        .toList(growable: false);
    final DailyLogModel resetLog = _recalculateLog(existing.copyWith(items: resetItems));
    _logsByDate[dateKey] = resetLog;
    return resetLog;
  }

  DailyLogModel _buildInitialLog(String dateKey) {
    final DateTime now = DateTime.now().toUtc();
    final List<DailyLogItem> items = _defaultCategories
        .map(
          (TrackerCategoryModel category) => DailyLogItemModel(
            id: '${dateKey}_${category.id}',
            category: category,
            completedCount: 0,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);
    return _recalculateLog(
      DailyLogModel(
        id: dateKey,
        userId: 'local_user',
        logDate: DateTime.parse('${dateKey}T00:00:00'),
        items: items,
        completionPercentage: 0,
        totalCompleted: 0,
        totalTarget: items.fold(0, (int sum, DailyLogItem item) => sum + item.targetCount),
        isFullyCompleted: false,
      ),
    );
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
      completionPercentage: completionPercentage,
      totalCompleted: totalCompleted,
      totalTarget: totalTarget,
      isFullyCompleted: totalCompleted >= totalTarget && totalTarget > 0,
    );
  }
}
