import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/auth/data/models/auth_session_model.dart';
import 'package:stay_alive/features/auth/data/models/auth_user_model.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';

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
    required AppLogger logger,
  })  : _account = account,
        _logger = logger;

  final Account _account;
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

    final appwrite_models.User<Map<String, dynamic>> user = await _account
        .get();
    return AuthUserModel.fromAppwrite(user);
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
    return AuthSessionModel.fromAppwrite(session);
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    final appwrite_models.User<Map<String, dynamic>> user = await _account
        .get();
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
    final appwrite_models.User<Map<String, dynamic>> currentUser = await _account
        .get();
    final Map<String, dynamic> prefs = <String, dynamic>{
      ...currentUser.prefs.data,
      ...preferences,
    };
    final appwrite_models.User<Map<String, dynamic>> updatedUser = await _account
        .updatePrefs(prefs: prefs);
    _logger.info('Updated user preferences', data: <String, Object?>{'userId': updatedUser.$id});
    return AuthUserModel.fromAppwrite(updatedUser);
  }

  @override
  Future<void> logout() {
    _logger.info('Logging out active session');
    return _account.deleteSession(sessionId: 'current');
  }
}
