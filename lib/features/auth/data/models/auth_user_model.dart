import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.emailVerified,
    required super.preferences,
  });

  factory AuthUserModel.fromAppwrite(
    appwrite_models.User<Map<String, dynamic>> user,
  ) {
    final dynamic prefs = user.prefs.data;
    final Map<String, dynamic> mappedPrefs = prefs is Map<String, dynamic>
        ? prefs
        : <String, dynamic>{};

    return AuthUserModel(
      id: user.$id,
      email: user.email,
      displayName: user.name,
      emailVerified: user.emailVerification,
      preferences: mappedPrefs,
    );
  }
}
