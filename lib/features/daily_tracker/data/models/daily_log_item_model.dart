import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';

class DailyLogItemModel extends DailyLogItem {
  const DailyLogItemModel({
    required super.category,
    required super.completedCount,
  });

  factory DailyLogItemModel.fromJson(Map<String, dynamic> json) {
    return DailyLogItemModel(
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
    );
  }

  factory DailyLogItemModel.fromEntity(DailyLogItem entity) {
    return DailyLogItemModel(
      category: entity.category,
      completedCount: entity.completedCount,
    );
  }

  @override
  DailyLogItemModel copyWith({
    TrackerCategory? category,
    int? completedCount,
  }) {
    return DailyLogItemModel(
      category: category ?? this.category,
      completedCount: completedCount ?? this.completedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'categoryId': category.id,
      'categoryTitle': category.title,
      'completedCount': completedCount,
      'targetCount': targetCount,
      'displayOrder': category.displayOrder,
      'description': category.description,
      'iconKey': category.iconKey,
    };
  }
}
