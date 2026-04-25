import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class RecordCompletedDayParams extends Equatable {
  const RecordCompletedDayParams({
    required this.dateKey,
    this.isEarlyLog = false,
  });

  final String dateKey;
  final bool isEarlyLog;

  @override
  List<Object?> get props => <Object?>[dateKey, isEarlyLog];
}

class RecordCompletedDayUseCase
    implements UseCase<UserGameProfile, RecordCompletedDayParams> {
  const RecordCompletedDayUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<UserGameProfile>> call(RecordCompletedDayParams params) =>
      _repository.recordCompletedDay(
        dateKey: params.dateKey,
        isEarlyLog: params.isEarlyLog,
      );
}
