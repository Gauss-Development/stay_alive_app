import 'package:stay_alive/features/daily_tracker/data/models/tracker_category_model.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';

class DailyLogItemModel extends DailyLogItem {
  const DailyLogItemModel({
    required super.id,
    required super.category,
    required super.completedCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DailyLogItemModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now().toUtc();
    return DailyLogItemModel(
      id: (json['id'] as String?) ?? (json['categoryId'] as String? ?? ''),
      category: TrackerCategory(
        id: json['categoryId'] as String,
        title: json['categoryTitle'] as String,
        description: json['description'] as String? ?? '',
        targetCount: json['targetCount'] as int,
        displayOrder: json['displayOrder'] as int,
        iconKey: json['iconKey'] as String? ?? '',
        isActive: true,
      ),
      completedCount: json['completedCount'] as int,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
    );
  }

  /// Builds an item from a `daily_log_items` row; the embedded category is
  /// reconstructed from the denormalized columns.
  factory DailyLogItemModel.fromRow(Map<String, dynamic> row) {
    final DateTime now = DateTime.now().toUtc();
    return DailyLogItemModel(
      id: row['id']?.toString() ?? '',
      category: TrackerCategoryModel(
        id: row['category_id']?.toString() ?? '',
        title:
            row['category_title']?.toString() ??
            row['category_id']?.toString() ??
            'Category',
        description: row['description']?.toString() ?? '',
        targetCount: (row['target_count'] as num?)?.toInt() ?? 0,
        displayOrder: (row['display_order'] as num?)?.toInt() ?? 0,
        iconKey: row['icon_key']?.toString() ?? 'default',
        isActive: row['is_active'] as bool? ?? true,
      ),
      completedCount: (row['completed_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? now,
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ?? now,
    );
  }

  factory DailyLogItemModel.fromEntity(DailyLogItem entity) {
    return DailyLogItemModel(
      id: entity.id,
      category: entity.category,
      completedCount: entity.completedCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  DailyLogItemModel copyWith({
    String? id,
    TrackerCategory? category,
    int? completedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLogItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      completedCount: completedCount ?? this.completedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'categoryId': category.id,
      'categoryTitle': category.title,
      'completedCount': completedCount,
      'targetCount': targetCount,
      'displayOrder': category.displayOrder,
      'description': category.description,
      'iconKey': category.iconKey,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Insert payload for `daily_log_items`. `id` comes from the column
  /// default, `user_id` from `default auth.uid()`.
  Map<String, dynamic> toCreateData({required String logId}) {
    return <String, dynamic>{
      'log_id': logId,
      'category_id': category.id,
      'category_title': category.title,
      'description': category.description,
      'target_count': targetCount,
      'display_order': category.displayOrder,
      'icon_key': category.iconKey,
      'is_active': category.isActive,
      'completed_count': completedCount,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateData() {
    return <String, dynamic>{
      'completed_count': completedCount,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}
