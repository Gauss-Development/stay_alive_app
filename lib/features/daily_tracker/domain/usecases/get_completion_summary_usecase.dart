import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/completion_summary.dart';

class GetCompletionSummaryUseCase {
  const GetCompletionSummaryUseCase();

  Result<CompletionSummary> call(DailyLog log) {
    if (log.totalTarget <= 0) {
      return const Left<Failure, CompletionSummary>(
        ValidationFailure('Daily target must be greater than zero.'),
      );
    }

    return Right<Failure, CompletionSummary>(
      CompletionSummary(
        totalCompleted: log.totalCompleted,
        totalTarget: log.totalTarget,
        completionPercentage: log.completionPercentage,
        isFullyCompleted: log.isFullyCompleted,
      ),
    );
  }
}

