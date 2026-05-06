import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/auth/data/models/auth_session_model.dart';
import 'package:stay_alive/features/auth/data/models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthSessionModel> loginWithOAuth({
    required appwrite_enums.OAuthProvider provider,
    String? success,
    String? failure,
    List<String>? scopes,
  });

  Future<AuthUserModel> getCurrentUser();

  Future<AuthSessionModel?> getCurrentSession();

  Future<AuthUserModel> updatePreferences({
    required Map<String, dynamic> preferences,
  });

  Future<void> logout();
}

class AppwriteAuthRemoteDataSource implements AuthRemoteDataSource {
  AppwriteAuthRemoteDataSource({
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
  Future<AuthSessionModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final appwrite_models.Session session = await _account
        .createEmailPasswordSession(
      email: email,
      password: password,
    );
    _logger.info(
      'Logged in with email',
      data: <String, Object?>{'email': email},
    );
    final appwrite_models.User user = await _account.get();
    await _ensureUserDocument(AuthUserModel.fromAppwrite(user));
    return AuthSessionModel.fromAppwrite(session);
  }

  @override
  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    _logger.info(
      'Created account with email',
      data: <String, Object?>{'email': email},
    );

    final appwrite_models.Session session = await _account
        .createEmailPasswordSession(
      email: email,
      password: password,
    );
    _logger.info(
      'Signed in after account creation',
      data: <String, Object?>{'sessionId': session.$id},
    );

    final appwrite_models.User user = await _account.get();
    final AuthUserModel authUser = AuthUserModel.fromAppwrite(user);
    await _ensureUserDocument(authUser);
    return authUser;
  }

  @override
  Future<AuthSessionModel> loginWithOAuth({
    required appwrite_enums.OAuthProvider provider,
    String? success,
    String? failure,
    List<String>? scopes,
  }) async {
    await _account.createOAuth2Session(
      provider: provider,
      success: success,
      failure: failure,
      scopes: scopes,
    );

    final appwrite_models.Session session = await _account.getSession(
      sessionId: 'current',
    );
    _logger.info(
      'Logged in with OAuth',
      data: <String, Object?>{'provider': provider.name},
    );
    final appwrite_models.User user = await _account.get();
    await _ensureUserDocument(AuthUserModel.fromAppwrite(user));
    return AuthSessionModel.fromAppwrite(session);
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    final appwrite_models.User user = await _account.get();
    await _ensureUserDocument(AuthUserModel.fromAppwrite(user));
    return AuthUserModel.fromAppwrite(user);
  }

  @override
  Future<AuthSessionModel?> getCurrentSession() async {
    try {
      final appwrite_models.Session session = await _account.getSession(
        sessionId: 'current',
      );
      return AuthSessionModel.fromAppwrite(session);
    } on AppwriteException catch (exception) {
      if (exception.code == 401) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AuthUserModel> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    final appwrite_models.User currentUser = await _account.get();
    final Map<String, dynamic> prefs = <String, dynamic>{
      ...currentUser.prefs.data,
      ...preferences,
    };
    final appwrite_models.User updatedUser = await _account.updatePrefs(
      prefs: prefs,
    );
    final AuthUserModel authUser = AuthUserModel.fromAppwrite(updatedUser);
    await _ensureUserDocument(authUser);
    if (preferences.containsKey('onboardingCompleted')) {
      await _updateUserDocument(
        authUser,
        <String, dynamic>{
          'onboarding_completed': preferences['onboardingCompleted'] == true,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }
    _logger.info(
      'Updated user preferences',
      data: <String, Object?>{'userId': updatedUser.$id},
    );
    return authUser;
  }

  @override
  Future<void> logout() {
    _logger.info('Logging out active session');
    return _account.deleteSession(sessionId: 'current');
  }

  Future<void> _ensureUserDocument(AuthUserModel user) async {
    try {
      await _databases.getDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.usersCollectionId,
        documentId: user.id,
      );
    } on AppwriteException catch (exception) {
      if (exception.code != 404) {
        rethrow;
      }
      await _createUserDocument(user);
    }
  }

  Future<void> _createUserDocument(AuthUserModel user) async {
    final String now = DateTime.now().toUtc().toIso8601String();
    await _databases.createDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.usersCollectionId,
      documentId: user.id,
      data: <String, dynamic>{
        'user_id': user.id,
        'email': user.email,
        'display_name': _displayNameFor(user),
        'avatar_url': '',
        'onboarding_completed': user.onboardingCompleted,
        'units_preference': 'metric',
        'locale': 'en',
        'created_at': now,
        'updated_at': now,
      },
      permissions: <String>[
        Permission.read(Role.user(user.id)),
        Permission.update(Role.user(user.id)),
        Permission.delete(Role.user(user.id)),
      ],
    );
    _logger.info(
      'Created Appwrite user profile document',
      data: <String, Object?>{'userId': user.id},
    );
  }

  Future<void> _updateUserDocument(
    AuthUserModel user,
    Map<String, dynamic> data,
  ) async {
    try {
      await _databases.updateDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.usersCollectionId,
        documentId: user.id,
        data: data,
      );
    } on AppwriteException catch (exception) {
      if (exception.code != 404) {
        rethrow;
      }
      await _createUserDocument(user);
      await _databases.updateDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.usersCollectionId,
        documentId: user.id,
        data: data,
      );
    }
  }

  String _displayNameFor(AuthUserModel user) {
    if (user.displayName.trim().isNotEmpty) {
      return user.displayName.trim();
    }
    final int separatorIndex = user.email.indexOf('@');
    if (separatorIndex <= 0) {
      return 'Stay Alive User';
    }
    return user.email.substring(0, separatorIndex);
  }
}
