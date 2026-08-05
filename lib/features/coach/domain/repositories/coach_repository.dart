import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';

abstract class CoachRepository {
  Future<Result<CoachResponse>> invoke({
    required CoachMode mode,
    required CoachContextPayload context,
    required bool isPremium,
  });
}
