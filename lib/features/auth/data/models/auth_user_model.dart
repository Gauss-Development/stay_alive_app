import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.emailVerified,
    required super.preferences,
  });

  factory AuthUserModel.fromSupabase(supabase.User user) {
    // Supabase keeps sign-up `data` and later preference updates in the same
    // user_metadata map, so it doubles as the preferences store. Consumers
    // read specific keys (`onboardingCompleted`); extra keys like `name` are
    // harmless.
    final Map<String, dynamic> metadata =
        user.userMetadata ?? <String, dynamic>{};

    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      displayName:
          (metadata['name'] ?? metadata['full_name'])?.toString() ?? '',
      emailVerified: user.emailConfirmedAt != null,
      preferences: metadata,
    );
  }
}
