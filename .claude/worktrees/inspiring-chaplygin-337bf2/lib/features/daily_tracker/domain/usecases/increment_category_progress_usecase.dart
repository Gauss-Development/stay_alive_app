import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/repositories/daily_tracker_repository.dart';

class IncrementCategoryProgressUseCase
    implements UseCase<DailyLog, IncrementCategoryProgressParams> {
  const IncrementCategoryProgressUseCase(this._repository);

  final DailyTrackerRepository _repository;

  @override
  Future<Result<DailyLog>> call(IncrementCategoryProgressParams params) {
    return _repository.incrementCategoryProgress(
      categoryId: params.categoryId,
    );
  }
}

class IncrementCategoryProgressParams extends Equatable {
  const IncrementCategoryProgressParams({
    required this.categoryId,
  });

  final String categoryId;

  @override
  List<Object?> get props => <Object?>[categoryId];
}
