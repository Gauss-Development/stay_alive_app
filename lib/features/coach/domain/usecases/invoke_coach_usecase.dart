import 'package:equatable/equatable.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/domain/repositories/coach_repository.dart';

class InvokeCoachUseCase implements UseCase<CoachResponse, InvokeCoachParams> {
  const InvokeCoachUseCase(this._repository);

  final CoachRepository _repository;

  @override
  Future<Result<CoachResponse>> call(InvokeCoachParams params) {
    return _repository.invoke(
      mode: params.mode,
      context: params.context,
      isPremium: params.isPremium,
    );
  }
}

class InvokeCoachParams extends Equatable {
  const InvokeCoachParams({
    required this.mode,
    required this.context,
    required this.isPremium,
  });

  final CoachMode mode;
  final CoachContextPayload context;
  final bool isPremium;

  @override
  List<Object?> get props => <Object?>[mode, context, isPremium];
}
