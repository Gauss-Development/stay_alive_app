import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.id,
    required super.userId,
    required super.provider,
    required super.expire,
  });

  factory AuthSessionModel.fromAppwrite(appwrite_models.Session session) {
    return AuthSessionModel(
      id: session.$id,
      userId: session.userId,
      provider: session.provider,
      expire: DateTime.parse(session.expire),
    );
  }
}
