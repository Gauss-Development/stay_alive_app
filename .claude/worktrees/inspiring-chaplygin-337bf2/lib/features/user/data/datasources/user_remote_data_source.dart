import 'package:appwrite/appwrite.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/user/data/models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileModel> fetchProfile();
}

class AppwriteUserRemoteDataSource implements UserRemoteDataSource {
  AppwriteUserRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
    required AppLogger logger,
  })  : _account = account,
        _databases = databases,
        _envConfig = envConfig,
        _logger = logger;

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;
  final AppLogger _logger;

  @override
  Future<UserProfileModel> fetchProfile() async {
    final user = await _account.get();
    _logger.debug(
      'Fetching user profile document',
      data: <String, Object?>{'documentId': user.$id},
    );

    final document = await _databases.getDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.usersCollectionId,
      documentId: user.$id,
    );

    return UserProfileModel.fromDocument(document);
  }
}
