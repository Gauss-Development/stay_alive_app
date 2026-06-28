import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

abstract class GamificationRepository {
  Future<Result<UserGameProfile>> reconcileProgress();
}
