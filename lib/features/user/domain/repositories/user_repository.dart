import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updatePreferences({
    required String unitsPreference,
    required String locale,
  });
}
