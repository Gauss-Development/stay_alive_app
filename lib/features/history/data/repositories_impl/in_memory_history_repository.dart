import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/history/domain/entities/daily_history_point.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';
import 'package:stay_alive/features/history/domain/repositories/history_repository.dart';

class InMemoryHistoryRepository implements HistoryRepository {
  @override
  Future<Result<HistorySummary>> getHistorySummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    const int totalDays = 30;
    const int completedDays = 22;
    const int currentStreak = 6;
    const double averageCompletion = 73.4;

    if (endDate.isBefore(startDate)) {
      return const Left<Failure, HistorySummary>(
        ValidationFailure('End date must be after start date.'),
      );
    }

    final DateTime end = DateTime.utc(endDate.year, endDate.month, endDate.day);
    final List<DailyHistoryPoint> dailyPoints =
        List<DailyHistoryPoint>.generate(totalDays, (int index) {
          final DateTime date = end.subtract(
            Duration(days: totalDays - index - 1),
          );
          final double completion = 40 + (index % 7) * 8.5;
          final int target = 24;
          final int completed = (target * completion / 100).round();
          return DailyHistoryPoint(
            date: date,
            completionPercentage: completion,
            totalCompleted: completed,
            totalTarget: target,
            isFullyCompleted: completion >= 100,
            hasLog: index % 5 != 0,
          );
        }, growable: false);

    return Right<Failure, HistorySummary>(
      HistorySummary(
        periodLabel: 'Last 30 days',
        averageCompletionPercentage: averageCompletion,
        completedDays: completedDays,
        totalDays: totalDays,
        currentStreak: currentStreak,
        bestStreak: 12,
        weeklyCompletionPercent: 78.1,
        monthlyCompletionPercent: averageCompletion,
        dailyPoints: dailyPoints,
      ),
    );
  }
}
