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
}
