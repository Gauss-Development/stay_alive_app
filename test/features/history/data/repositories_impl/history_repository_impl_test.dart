import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/history/data/datasources/history_remote_data_source.dart';
import 'package:stay_alive/features/history/data/repositories_impl/history_repository_impl.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';

class _FakeHistoryRemoteDataSource implements HistoryRemoteDataSource {
  _FakeHistoryRemoteDataSource(this.logs);

  final List<DailyLogModel> logs;

  @override
  Future<List<DailyLogModel>> fetchLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return logs;
  }
}

void main() {
  group('HistoryRepositoryImpl', () {
    test('returns validation failure for invalid date range', () async {
      final HistoryRepositoryImpl repository = HistoryRepositoryImpl(
        _FakeHistoryRemoteDataSource(const <DailyLogModel>[]),
      );

      final result = await repository.getHistorySummary(
        startDate: DateTime.utc(2026, 5, 7),
        endDate: DateTime.utc(2026, 5, 6),
      );

      expect(result.isLeft(), isTrue);
    });

    test('calculates period averages and streaks from fetched logs', () async {
      final HistoryRepositoryImpl repository = HistoryRepositoryImpl(
        _FakeHistoryRemoteDataSource(<DailyLogModel>[
          _log('2026-05-01', completed: 24, target: 24),
          _log('2026-05-02', completed: 24, target: 24),
          _log('2026-05-04', completed: 12, target: 24),
          _log('2026-05-05', completed: 24, target: 24),
          _log('2026-05-06', completed: 24, target: 24),
        ]),
      );

      final result = await repository.getHistorySummary(
        startDate: DateTime.utc(2026, 5),
        endDate: DateTime.utc(2026, 5, 6),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected summary'),
        (HistorySummary summary) {
          expect(summary.totalDays, 6);
          expect(summary.completedDays, 4);
          expect(summary.currentStreak, 2);
          expect(summary.bestStreak, 2);
          expect(summary.averageCompletionPercentage, 90);
          expect(summary.dailyPoints, hasLength(6));
          expect(summary.dailyPoints.first.dateKey, '2026-05-01');
          expect(summary.dailyPoints[2].hasLog, isFalse);
          expect(summary.dailyPoints[2].completionPercentage, 0);
          expect(summary.pointsForLastDays(2), hasLength(2));
        },
      );
    });
  });
}

DailyLogModel _log(
  String dateKey, {
  required int completed,
  required int target,
}) {
  final double completion = target == 0 ? 0 : (completed / target) * 100;
  return DailyLogModel(
    id: dateKey,
    userId: 'user_1',
    logDate: DateTime.parse('${dateKey}T00:00:00Z'),
    items: const <Never>[],
    totalCompleted: completed,
    totalTarget: target,
    completionPercentage: completion,
    isFullyCompleted: target > 0 && completed >= target,
  );
}
