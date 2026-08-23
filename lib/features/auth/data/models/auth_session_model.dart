import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.id,
    required super.userId,
    required super.provider,
    required super.expire,
  });

  factory AuthSessionModel.fromSupabase(supabase.Session session) {
    // `expiresAt` is seconds since epoch. Supabase sessions auto-refresh, so
    // the expiry is informational, not a hard logout deadline.
    final int? expiresAt = session.expiresAt;
    return AuthSessionModel(
      id: session.user.id,
      userId: session.user.id,
      provider: session.user.appMetadata['provider']?.toString() ?? 'email',
      expire: expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true)
          : DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
  }
}
