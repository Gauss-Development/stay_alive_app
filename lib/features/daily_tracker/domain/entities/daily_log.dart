import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

class DailyLog extends Equatable {
  const DailyLog({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.items,
    required this.totalCompleted,
    required this.totalTarget,
    required this.completionPercentage,
    required this.isFullyCompleted,
  });

  final String id;
  final String userId;
  final DateTime logDate;
  final List<DailyLogItem> items;
  final int totalCompleted;
  final int totalTarget;
  final double completionPercentage;
  final bool isFullyCompleted;

  String get dateKey {
    final String month = logDate.month.toString().padLeft(2, '0');
    final String day = logDate.day.toString().padLeft(2, '0');
    return '${logDate.year}-$month-$day';
  }

  DailyLog copyWith({
    List<DailyLogItem>? items,
    int? totalCompleted,
    int? totalTarget,
    double? completionPercentage,
    bool? isFullyCompleted,
  }) {
    return DailyLog(
      id: id,
      userId: userId,
      logDate: logDate,
      items: items ?? this.items,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalTarget: totalTarget ?? this.totalTarget,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isFullyCompleted: isFullyCompleted ?? this.isFullyCompleted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        logDate,
        items,
        totalCompleted,
        totalTarget,
        completionPercentage,
        isFullyCompleted,
      ];
}
