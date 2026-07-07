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

  /// Dev-only: creates a real Appwrite anonymous session (throwaway user).
  Future<AuthUserModel> createAnonymousSession();

  Future<AuthUserModel> updatePreferences({
    required Map<String, dynamic> preferences,
  });

  Future<void> logout();

  Future<void> deleteAccount();
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
    await _deleteCurrentSessionIfActive();
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
    await _deleteCurrentSessionIfActive();
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

    await _createEmailPasswordSessionIfNeeded(
      email: email,
      password: password,
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
    await _deleteCurrentSessionIfActive();
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
  Future<AuthUserModel> createAnonymousSession() async {
    await _deleteCurrentSessionIfActive();
    await _account.createAnonymousSession();
    _logger.info('Created anonymous session (dev mock login)');
    // Land the throwaway user straight on the home shell.
    await _account.updatePrefs(
      prefs: <String, dynamic>{'onboardingCompleted': true},
    );
    final appwrite_models.User user = await _account.get();
    final AuthUserModel authUser = AuthUserModel.fromAppwrite(user);
    await _ensureUserDocument(authUser);
    return authUser;
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
      await _syncOnboardingToProfileDocument(authUser, preferences);
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

  @override
  Future<void> deleteAccount() async {
    final appwrite_models.User user = await _account.get();
    final String userId = user.$id;
    _logger.info(
      'Deleting account and user data',
      data: <String, Object?>{'userId': userId},
    );

    final List<String> collectionsByUserId = <String>[
      _envConfig.dailyLogsCollectionId,
      _envConfig.dailyLogItemsCollectionId,
      _envConfig.subscriptionsCollectionId,
      _envConfig.analyticsEventsCollectionId,
      _envConfig.gamificationProfilesCollectionId,
      _envConfig.gamificationEventsCollectionId,
    ];
    for (final String collectionId in collectionsByUserId) {
      await _deleteDocumentsByUserId(collectionId: collectionId, userId: userId);
    }

    await _deleteDocumentIfExists(
      collectionId: _envConfig.usersCollectionId,
      documentId: userId,
    );

    await _account.deleteSessions();
  }

  Future<void> _deleteDocumentsByUserId({
    required String collectionId,
    required String userId,
  }) async {
    while (true) {
      final appwrite_models.DocumentList page = await _databases.listDocuments(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: collectionId,
        queries: <String>[
        Query.limit(100),
      ],
      );
      if (page.documents.isEmpty) {
        return;
      }
      for (final appwrite_models.Document document in page.documents) {
        try {
          await _databases.deleteDocument(
            databaseId: _envConfig.appwriteDatabaseId,
            collectionId: collectionId,
            documentId: document.$id,
          );
        } on AppwriteException catch (exception) {
          if (exception.code != 404) {
            rethrow;
          }
        }
      }
    }
  }

  Future<void> _deleteDocumentIfExists({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      await _databases.deleteDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
    } on AppwriteException catch (exception) {
      if (exception.code != 404) {
        rethrow;
      }
    }
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
    await _databases.createDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.usersCollectionId,
      documentId: user.id,
      data: _userDocumentDataForCreate(user),
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

  /// Payload for the deployed Stay Alive `users` collection.
  ///
  /// The live Appwrite schema uses the Auth user id as the document id and
  /// stores `name` + `email` only. Extra fields from
  /// [scripts/appwrite_provision.py] (e.g. `user_id`, `display_name`) are not
  /// present on the console-provisioned collection.
  Map<String, dynamic> _userDocumentDataForCreate(AuthUserModel user) {
    return <String, dynamic>{
      'email': _emailForUserDocument(user),
      'name': _displayNameFor(user),
    };
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

  /// Best-effort mirror of onboarding into the profile document when the
  /// collection supports it. Auth prefs remain the source of truth.
  Future<void> _syncOnboardingToProfileDocument(
    AuthUserModel user,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _updateUserDocument(
        user,
        <String, dynamic>{
          'onboarding_completed': preferences['onboardingCompleted'] == true,
        },
      );
    } on AppwriteException catch (exception) {
      _logger.warning(
        'Skipped onboarding sync to users collection',
        data: <String, Object?>{'reason': exception.message},
      );
    }
  }

  /// Appwrite 1.5+ rejects new sessions while one is already stored on device.
  Future<void> _deleteCurrentSessionIfActive() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _logger.info('Cleared active Appwrite session before creating a new one');
    } on AppwriteException catch (exception) {
      if (exception.code != 401) {
        rethrow;
      }
    }
  }

  Future<void> _createEmailPasswordSessionIfNeeded({
    required String email,
    required String password,
  }) async {
    try {
      final appwrite_models.Session session = await _account
          .createEmailPasswordSession(
        email: email,
        password: password,
      );
      _logger.info(
        'Signed in after account creation',
        data: <String, Object?>{'sessionId': session.$id},
      );
    } on AppwriteException catch (exception) {
      if (!_isSessionAlreadyActiveError(exception)) {
        rethrow;
      }
      _logger.info(
        'Skipped email session creation after sign-up; account already has an active session',
      );
    }
  }

  bool _isSessionAlreadyActiveError(AppwriteException exception) {
    final String message = exception.message?.toLowerCase() ?? '';
    return message.contains('session is prohibited') ||
        message.contains('session is active');
  }

  String _displayNameFor(AuthUserModel user) {
    if (user.displayName.trim().isNotEmpty) {
      return user.displayName.trim();
    }
    final String email = user.email.trim();
    final int separatorIndex = email.indexOf('@');
    if (separatorIndex <= 0) {
      return 'Stay Alive User';
    }
    return email.substring(0, separatorIndex);
  }

  /// Anonymous/guest Appwrite users have no email; the `users` collection
  /// requires one, so we store a stable synthetic address keyed by user id.
  String _emailForUserDocument(AuthUserModel user) {
    final String email = user.email.trim();
    if (email.isNotEmpty) {
      return email;
    }
    return '${user.id}@guest.stayalive.local';
  }
}
