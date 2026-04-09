import 'package:dartz/dartz.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';
import 'package:stay_alive/features/user/domain/repositories/user_repository.dart';

class InMemoryUserRepository implements UserRepository {
  UserProfile _profile = const UserProfile(
    userId: 'local_user',
    email: 'demo@dailydozen.app',
    displayName: 'Daily Dozen User',
    onboardingCompleted: true,
    unitsPreference: 'metric',
    locale: 'en',
  );

  @override
  Future<Result<UserProfile>> getProfile() async {
    return Right<Failure, UserProfile>(_profile);
  }

  @override
  Future<Result<UserProfile>> updatePreferences({
    required String unitsPreference,
    required String locale,
  }) async {
    _profile = UserProfile(
      userId: _profile.userId,
      email: _profile.email,
      displayName: _profile.displayName,
      onboardingCompleted: _profile.onboardingCompleted,
      unitsPreference: unitsPreference,
      locale: locale,
    );
    return Right<Failure, UserProfile>(_profile);
  }
}
