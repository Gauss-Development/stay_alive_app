import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/daily_tracker/data/daily_log_document_ids.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

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
          .map((DailyLogItem item) => DailyLogItemModel.fromEntity(item))
          .toList(growable: false),
      completionPercentage: entity.completionPercentage,
      totalCompleted: entity.totalCompleted,
      totalTarget: entity.totalTarget,
      isFullyCompleted: entity.isFullyCompleted,
    );
  }

  factory DailyLogModel.fromDocument({
    required appwrite_models.Document document,
    required List<DailyLogItemModel> items,
  }) {
    final Map<String, dynamic> data = document.data;
    final String? dateKey =
        DailyLogDocumentIds.dateKeyFromLogDocumentId(document.$id) ??
        data['log_date']?.toString();
    final String userId =
        DailyLogDocumentIds.userIdFromLogDocumentId(document.$id) ??
        data['user_id']?.toString() ??
        '';

    return DailyLogModel(
      id: document.$id,
      userId: userId,
      logDate: DateTime.parse('${dateKey ?? '1970-01-01'}T00:00:00Z'),
      items: items,
      totalCompleted: (data['total_completed'] as num?)?.toInt() ?? 0,
      totalTarget: (data['total_target'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (data['completion_percentage'] as num?)?.toDouble() ?? 0,
      isFullyCompleted: data['is_fully_completed'] as bool? ?? false,
    );
  }

  @override
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

  /// Payload for the `stay_alive_v1` `daily_logs` collection.
  Map<String, dynamic> toCreateData() {
    return <String, dynamic>{
      'log_date': dateKey,
      'completion_percentage': completionPercentage,
      'total_completed': totalCompleted,
      'total_target': totalTarget,
      'is_fully_completed': isFullyCompleted,
      'created_at': logDate.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateData() {
    return <String, dynamic>{
      'completion_percentage': completionPercentage,
      'total_completed': totalCompleted,
      'total_target': totalTarget,
      'is_fully_completed': isFullyCompleted,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
