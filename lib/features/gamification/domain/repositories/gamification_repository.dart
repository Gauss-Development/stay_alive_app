import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';

abstract class GamificationRepository {
  Future<Result<GamificationProgress>> getProgress();
}
