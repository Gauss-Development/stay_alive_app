import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/history/domain/entities/history_summary.dart';

abstract class HistoryRepository {
  Future<Result<HistorySummary>> getHistorySummary({
    required DateTime startDate,
    required DateTime endDate,
  });
}
