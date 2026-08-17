import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/appwrite_failure_mapper.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/user/data/datasources/user_remote_data_source.dart';
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';
import 'package:stay_alive/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final profile = await _remoteDataSource.fetchProfile();
      return Right<Failure, UserProfile>(profile);
    } on FormatException catch (e) {
      return Left<Failure, UserProfile>(
        ValidationFailure(e.message),
      );
    } catch (e) {
      return Left<Failure, UserProfile>(mapExceptionToFailure(e));
    }
  }
}
