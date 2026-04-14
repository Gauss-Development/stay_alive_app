import 'package:equatable/equatable.dart';

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
  });

  final String periodLabel;
  final double averageCompletionPercentage;
  final int completedDays;
  final int totalDays;
  final int currentStreak;
  final int bestStreak;
  final double weeklyCompletionPercent;
  final double monthlyCompletionPercent;

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
      ];
}
