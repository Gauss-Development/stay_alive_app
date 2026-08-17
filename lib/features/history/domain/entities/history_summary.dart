import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/history/domain/entities/daily_history_point.dart';

class HistorySummary extends Equatable {
  const HistorySummary({
    required this.periodLabel,
    required this.averageCompletionPercentage,
    required this.completedDays,
    required this.totalDays,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyCompletionPercent,
    required this.monthlyCompletionPercent,
    required this.dailyPoints,
  });

  final String periodLabel;
  final double averageCompletionPercentage;
  final int completedDays;
  final int totalDays;
  final int currentStreak;
  final int bestStreak;
  final double weeklyCompletionPercent;
  final double monthlyCompletionPercent;
  final List<DailyHistoryPoint> dailyPoints;

  List<DailyHistoryPoint> pointsForLastDays(int days) {
    if (dailyPoints.isEmpty || days <= 0) {
      return const <DailyHistoryPoint>[];
    }
    final int startIndex = dailyPoints.length > days
        ? dailyPoints.length - days
        : 0;
    return dailyPoints.sublist(startIndex);
  }

  @override
  List<Object?> get props => <Object?>[
    periodLabel,
    averageCompletionPercentage,
    completedDays,
    totalDays,
    currentStreak,
    bestStreak,
    weeklyCompletionPercent,
    monthlyCompletionPercent,
    dailyPoints,
  ];
}
