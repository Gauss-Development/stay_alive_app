import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';

class InitializeTodayLogUseCase
    implements UseCase<DailyLog, NoParams> {
  const InitializeTodayLogUseCase(this._repository);

  final DailyTrackerRepository _repository;

  @override
  Future<Result<DailyLog>> call(NoParams params) {
    return _repository.initializeTodayLog();
  }
}
