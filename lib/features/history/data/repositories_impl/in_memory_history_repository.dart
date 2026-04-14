import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
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

    return const Right<Failure, HistorySummary>(
      HistorySummary(
        periodLabel: 'Last 30 days',
        averageCompletionPercentage: averageCompletion,
        completedDays: completedDays,
        totalDays: totalDays,
        currentStreak: currentStreak,
        bestStreak: 12,
        weeklyCompletionPercent: 78.1,
        monthlyCompletionPercent: averageCompletion,
      ),
    );
  }
}
