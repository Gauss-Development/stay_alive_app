import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';

class TrackerCategoryModel extends TrackerCategory {
  const TrackerCategoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.targetCount,
    required super.displayOrder,
    required super.iconKey,
  });

  factory TrackerCategoryModel.fromJson(Map<String, dynamic> data) {
    return TrackerCategoryModel(
      id: (data['id'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      targetCount: (data['targetCount'] as num?)?.toInt() ?? 0,
      displayOrder: (data['displayOrder'] as num?)?.toInt() ?? 0,
      iconKey: (data['iconKey'] as String?) ?? 'default',
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'targetCount': targetCount,
      'displayOrder': displayOrder,
      'iconKey': iconKey,
      'isActive': isActive,
    };
  }
}
