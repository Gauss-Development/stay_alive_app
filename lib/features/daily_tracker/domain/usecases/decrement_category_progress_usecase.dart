import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';

class DecrementCategoryProgressUseCase
    implements UseCase<DailyLog, DecrementCategoryProgressParams> {
  const DecrementCategoryProgressUseCase(this._repository);

  final DailyTrackerRepository _repository;

  @override
  Future<Result<DailyLog>> call(DecrementCategoryProgressParams params) {
    return _repository.decrementCategoryProgress(
      categoryId: params.categoryId,
    );
  }
}

class DecrementCategoryProgressParams extends Equatable {
  const DecrementCategoryProgressParams({
    required this.categoryId,
  });

  final String categoryId;

  @override
  List<Object?> get props => <Object?>[categoryId];
}
