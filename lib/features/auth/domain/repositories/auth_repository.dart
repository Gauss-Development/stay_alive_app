import 'package:stay_alive/core/result/result.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_session.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';

enum OAuthSignInProvider {
  google,
  apple,
}

abstract class AuthRepository {
  Future<Result<AuthSession>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<AuthSession>> loginWithOAuth({
    required OAuthSignInProvider provider,
  });

  Future<Result<AuthUser>> getCurrentUser();

  Future<Result<AuthSession>> checkSession();

  Future<Result<void>> logout();

  Future<Result<AuthUser>> markOnboardingCompleted();
}

