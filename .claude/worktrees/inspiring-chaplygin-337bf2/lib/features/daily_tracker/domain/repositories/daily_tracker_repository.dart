import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';

abstract class DailyTrackerRepository {
  Future<Result<DailyLog>> initializeTodayLog();

  Future<Result<DailyLog>> getTodayLog();

  Future<Result<DailyLog>> incrementCategoryProgress({
    required String categoryId,
  });

  Future<Result<DailyLog>> decrementCategoryProgress({
    required String categoryId,
  });

  Future<Result<DailyLog>> resetTodayLog();
}
