import 'package:equatable/equatable.dart';

class DailyHistoryPoint extends Equatable {
  const DailyHistoryPoint({
    required this.date,
    required this.completionPercentage,
    required this.totalCompleted,
    required this.totalTarget,
    required this.isFullyCompleted,
    required this.hasLog,
  });

  final DateTime date;
  final double completionPercentage;
  final int totalCompleted;
  final int totalTarget;
  final bool isFullyCompleted;
  final bool hasLog;

  String get dateKey {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  List<Object?> get props => <Object?>[
    date,
    completionPercentage,
    totalCompleted,
    totalTarget,
    isFullyCompleted,
    hasLog,
  ];
}
