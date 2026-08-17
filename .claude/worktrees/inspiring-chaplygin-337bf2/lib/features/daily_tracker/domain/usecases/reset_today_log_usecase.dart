import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';

class ResetTodayLogUseCase implements UseCase<DailyLog, ResetTodayLogParams> {
  const ResetTodayLogUseCase(this._repository);

  final DailyTrackerRepository _repository;

  @override
  Future<Result<DailyLog>> call(ResetTodayLogParams params) {
    return _repository.resetTodayLog();
  }
}

class ResetTodayLogParams extends Equatable {
  const ResetTodayLogParams();

  @override
  List<Object?> get props => <Object?>[];
}
