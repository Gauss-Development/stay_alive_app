import 'package:appwrite/models.dart' as appwrite_models;
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

  factory DailyLogItemModel.fromDocument({
    required appwrite_models.Document document,
    required TrackerCategory category,
  }) {
    final Map<String, dynamic> data = document.data;
    final DateTime now = DateTime.now().toUtc();
    return DailyLogItemModel(
      id: document.$id,
      category: category,
      completedCount: (data['completed_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.tryParse(document.$createdAt) ??
          now,
      updatedAt: DateTime.tryParse(data['updated_at']?.toString() ?? '') ??
          DateTime.tryParse(document.$updatedAt) ??
          now,
    );
  }

  factory DailyLogItemModel.fromDocumentWithoutCategory(
    appwrite_models.Document document,
  ) {
    final Map<String, dynamic> data = document.data;
    return DailyLogItemModel.fromDocument(
      document: document,
      category: TrackerCategoryModel(
        id: data['category_id']?.toString() ?? '',
        title: data['category_title']?.toString() ??
            data['category_id']?.toString() ??
            'Category',
        description: data['description']?.toString() ?? '',
        targetCount: (data['target_count'] as num?)?.toInt() ?? 0,
        displayOrder: (data['display_order'] as num?)?.toInt() ?? 0,
        iconKey: data['icon_key']?.toString() ?? 'default',
        isActive: data['is_active'] as bool? ?? true,
      ),
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

  Map<String, dynamic> toCreateData({
    required String logId,
    required String userId,
  }) {
    return <String, dynamic>{
      'item_id': id,
      'log_id': logId,
      'user_id': userId,
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
