import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/history/data/datasources/history_remote_data_source.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';
import 'package:stay_alive/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._remoteDataSource);

  final HistoryRemoteDataSource _remoteDataSource;

  @override
  Future<Result<HistorySummary>> getHistorySummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (endDate.isBefore(startDate)) {
      return const Left<Failure, HistorySummary>(
        ValidationFailure('End date must be after start date.'),
      );
    }

    try {
      final List<DailyLogModel> logs = await _remoteDataSource.fetchLogs(
        startDate: startDate,
        endDate: endDate,
      );
      return Right<Failure, HistorySummary>(
        _buildSummary(startDate: startDate, endDate: endDate, logs: logs),
      );
    } catch (exception) {
      return Left<Failure, HistorySummary>(mapExceptionToFailure(exception));
    }
  }

  HistorySummary _buildSummary({
    required DateTime startDate,
    required DateTime endDate,
    required List<DailyLogModel> logs,
  }) {
    final int totalDays = _daysInclusive(startDate, endDate);
    final int completedDays = logs
        .where((DailyLogModel log) => log.isFullyCompleted)
        .length;
    final double averageCompletion = logs.isEmpty
        ? 0
        : logs.fold<double>(
              0,
              (double sum, DailyLogModel log) =>
                  sum + log.completionPercentage,
            ) /
            logs.length;

    final Set<String> completedDateKeys = logs
        .where((DailyLogModel log) => log.isFullyCompleted)
        .map((DailyLogModel log) => log.dateKey)
        .toSet();

    final int bestStreak = _calculateBestStreak(completedDateKeys);
    final int currentStreak = _calculateCurrentStreak(
      completedDateKeys,
      _dateKey(endDate),
    );

    final DateTime weekStart = endDate.subtract(const Duration(days: 6));
    final List<DailyLogModel> weeklyLogs = logs.where((DailyLogModel log) {
      final DateTime date = DateTime.parse('${log.dateKey}T00:00:00Z');
      return !date.isBefore(_dateOnly(weekStart));
    }).toList(growable: false);

    return HistorySummary(
      periodLabel: totalDays <= 31 ? 'Last $totalDays days' : 'Custom period',
      averageCompletionPercentage: averageCompletion,
      completedDays: completedDays,
      totalDays: totalDays,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      weeklyCompletionPercent: _averageCompletion(weeklyLogs),
      monthlyCompletionPercent: averageCompletion,
    );
  }

  double _averageCompletion(List<DailyLogModel> logs) {
    if (logs.isEmpty) {
      return 0;
    }
    return logs.fold<double>(
          0,
          (double sum, DailyLogModel log) =>
              sum + log.completionPercentage,
        ) /
        logs.length;
  }

  int _calculateBestStreak(Set<String> completedDateKeys) {
    if (completedDateKeys.isEmpty) {
      return 0;
    }
    final List<String> sorted = completedDateKeys.toList()..sort();
    int best = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i += 1) {
      final DateTime previous = DateTime.parse('${sorted[i - 1]}T00:00:00Z');
      final DateTime next = DateTime.parse('${sorted[i]}T00:00:00Z');
      if (next.difference(previous).inDays == 1) {
        current += 1;
        if (current > best) {
          best = current;
        }
      } else {
        current = 1;
      }
    }
    return best;
  }

  int _calculateCurrentStreak(Set<String> completedDateKeys, String endKey) {
    int streak = 0;
    DateTime cursor = DateTime.parse('${endKey}T00:00:00Z');
    while (completedDateKeys.contains(_dateKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _daysInclusive(DateTime startDate, DateTime endDate) {
    return _dateOnly(endDate).difference(_dateOnly(startDate)).inDays + 1;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day);
  }

  String _dateKey(DateTime value) {
    final DateTime date = _dateOnly(value);
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
