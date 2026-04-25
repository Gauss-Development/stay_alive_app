import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/repositories/gamification_repository.dart';

class AwardXpParams extends Equatable {
  const AwardXpParams({required this.amount, this.categoriesCompleted = 0});

  final int amount;
  final int categoriesCompleted;

  @override
  List<Object?> get props => <Object?>[amount, categoriesCompleted];
}

class AwardXpUseCase implements UseCase<UserGameProfile, AwardXpParams> {
  const AwardXpUseCase(this._repository);

  final GamificationRepository _repository;

  @override
  Future<Result<UserGameProfile>> call(AwardXpParams params) =>
      _repository.awardXp(
        amount: params.amount,
        categoriesCompleted: params.categoriesCompleted,
      );
}
