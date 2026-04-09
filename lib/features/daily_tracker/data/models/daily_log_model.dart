import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';

class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.userId,
    required super.logDate,
    required super.items,
    required super.totalCompleted,
    required super.totalTarget,
    required super.completionPercentage,
    required super.isFullyCompleted,
  });

  factory DailyLogModel.fromEntity(DailyLog entity) {
    return DailyLogModel(
      id: entity.id,
      userId: entity.userId,
      logDate: entity.logDate,
      items: entity.items
          .map(
            (DailyLogItem item) => DailyLogItemModel.fromEntity(item),
          )
          .toList(growable: false),
      completionPercentage: entity.completionPercentage,
      totalCompleted: entity.totalCompleted,
      totalTarget: entity.totalTarget,
      isFullyCompleted: entity.isFullyCompleted,
    );
  }

  DailyLogModel copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    List<DailyLogItem>? items,
    int? totalCompleted,
    int? totalTarget,
    double? completionPercentage,
    bool? isFullyCompleted,
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      items: items ?? this.items,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalTarget: totalTarget ?? this.totalTarget,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isFullyCompleted: isFullyCompleted ?? this.isFullyCompleted,
    );
  }
}
