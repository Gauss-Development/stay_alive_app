import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/tracker_category_model.dart';

void main() {
  group('TrackerCategoryModel', () {
    test('maps snake_case Appwrite data', () {
      final TrackerCategoryModel category = TrackerCategoryModel.fromJson(
        const <String, dynamic>{
          'category_id': 'whole_grains',
          'title': 'Whole Grains',
          'description': 'Track grain servings',
          'target_count': 3,
          'display_order': 10,
          'icon_key': 'whole_grains',
          'is_active': true,
        },
      );

      expect(category.id, 'whole_grains');
      expect(category.targetCount, 3);
      expect(category.displayOrder, 10);
      expect(category.toJson()['target_count'], 3);
    });
  });

  group('DailyLogItemModel', () {
    test('serializes Appwrite create and update payloads', () {
      final DateTime now = DateTime.utc(2026, 5, 6, 12);
      const TrackerCategoryModel category = TrackerCategoryModel(
        id: 'beans',
        title: 'Beans',
        description: 'Track beans',
        targetCount: 3,
        displayOrder: 1,
        iconKey: 'beans',
        isActive: true,
      );
      final DailyLogItemModel item = DailyLogItemModel(
        id: '2026-05-06_beans',
        category: category,
        completedCount: 2,
        createdAt: now,
        updatedAt: now,
      );

      final Map<String, dynamic> createData = item.toCreateData(
        logId: '2026-05-06',
        userId: 'user_1',
      );
      final Map<String, dynamic> updateData = item.toUpdateData();

      expect(createData.containsKey('item_id'), isFalse);
      expect(createData.containsKey('log_id'), isFalse);
      expect(createData.containsKey('user_id'), isFalse);
      expect(createData['category_id'], 'beans');
      expect(createData['completed_count'], 2);
      expect(updateData, containsPair('completed_count', 2));
      expect(updateData.containsKey('updated_at'), isFalse);
    });
  });

  group('DailyLogModel', () {
    test('serializes Appwrite create and update payloads', () {
      final DailyLogModel log = DailyLogModel(
        id: '2026-05-06',
        userId: 'user_1',
        logDate: DateTime.utc(2026, 5, 6),
        items: const <DailyLogItemModel>[],
        totalCompleted: 6,
        totalTarget: 24,
        completionPercentage: 25,
        isFullyCompleted: false,
      );

      final Map<String, dynamic> createData = log.toCreateData();
      final Map<String, dynamic> updateData = log.toUpdateData();

      expect(createData.containsKey('log_id'), isFalse);
      expect(createData.containsKey('user_id'), isFalse);
      expect(createData.containsKey('log_date'), isFalse);
      expect(createData['completion_percentage'], 25);
      expect(updateData['total_completed'], 6);
      expect(updateData['total_target'], 24);
      expect(updateData.containsKey('updated_at'), isFalse);
    });
  });
}
