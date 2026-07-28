import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';

class TrackerCategoryModel extends TrackerCategory {
  const TrackerCategoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.targetCount,
    required super.displayOrder,
    required super.iconKey,
    required super.isActive,
  });

  factory TrackerCategoryModel.fromJson(Map<String, dynamic> data) {
    return TrackerCategoryModel(
      id: (data['category_id'] as String?) ?? (data['id'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      targetCount:
          (data['target_count'] as num?)?.toInt() ??
          (data['targetCount'] as num?)?.toInt() ??
          0,
      displayOrder:
          (data['display_order'] as num?)?.toInt() ??
          (data['displayOrder'] as num?)?.toInt() ??
          0,
      iconKey:
          (data['icon_key'] as String?) ??
          (data['iconKey'] as String?) ??
          'default',
      isActive:
          (data['is_active'] as bool?) ?? (data['isActive'] as bool?) ?? true,
    );
  }

  factory TrackerCategoryModel.fromDocument(appwrite_models.Document document) {
    return TrackerCategoryModel.fromJson(<String, dynamic>{
      ...document.data,
      'category_id': document.data['category_id'] ?? document.$id,
    });
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category_id': id,
      'title': title,
      'description': description,
      'target_count': targetCount,
      'display_order': displayOrder,
      'icon_key': iconKey,
      'is_active': isActive,
    };
  }
}
