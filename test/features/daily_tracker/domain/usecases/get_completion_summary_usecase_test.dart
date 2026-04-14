import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/tracker_category.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';
import 'package:stay_alive/features/daily_tracker/domain/usecases/get_completion_summary_usecase.dart';

void main() {
  group('GetCompletionSummaryUseCase', () {
    const GetCompletionSummaryUseCase useCase = GetCompletionSummaryUseCase();

    test('returns completion summary for valid log', () {
      final DailyLog log = _buildLog(totalTarget: 10, totalCompleted: 4);

      final result = useCase(log);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right result'),
        (CompletionSummary summary) {
          expect(summary.totalCompleted, 4);
          expect(summary.totalTarget, 10);
          expect(summary.completionPercentage, 40);
          expect(summary.isFullyCompleted, isFalse);
        },
      );
    });

    test('returns validation failure when target is zero', () {
      final DailyLog log = _buildLog(totalTarget: 0, totalCompleted: 0);

      final result = useCase(log);

      expect(result.isLeft(), isTrue);
      result.fold(
        (Failure failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Expected left result'),
      );
    });
  });
}

DailyLog _buildLog({
  required int totalTarget,
  required int totalCompleted,
}) {
  const TrackerCategory category = TrackerCategory(
    id: 'beans',
    title: 'Beans',
    description: 'Track beans',
    targetCount: 3,
    displayOrder: 1,
    iconKey: 'beans',
    isActive: true,
  );

  final DailyLogItem item = DailyLogItem(
    id: 'item_1',
    category: category,
    completedCount: totalCompleted,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  return DailyLog(
    id: 'log_1',
    userId: 'user_1',
    logDate: DateTime.utc(2026, 1, 1),
    items: <DailyLogItem>[item],
    totalCompleted: totalCompleted,
    totalTarget: totalTarget,
    completionPercentage: totalTarget == 0 ? 0 : (totalCompleted / totalTarget) * 100,
    isFullyCompleted: totalTarget > 0 && totalCompleted >= totalTarget,
  );
}
