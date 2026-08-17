import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/coach/data/datasources/coach_remote_data_source.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl(this._remote);

  final CoachRemoteDataSource _remote;

  @override
  Future<Result<CoachResponse>> invoke({
    required CoachMode mode,
    required CoachContextPayload context,
    required bool isPremium,
  }) async {
    try {
      if (!isPremium &&
          (mode == CoachMode.chat ||
              mode == CoachMode.weeklyInsight ||
              mode == CoachMode.personalizeChallenge)) {
        return const Left(
          PermissionFailure(
            'AI coach chat and insights require Stay Alive Pro',
          ),
        );
      }

      final CoachResponse response = await _remote.invoke(
        mode: mode,
        context: context,
        isPremium: isPremium,
      );
      return Right(response);
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }
}
