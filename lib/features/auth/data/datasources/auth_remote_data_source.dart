import 'dart:async';

import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/core/supabase/supabase_tables.dart';
import 'package:stay_alive/features/auth/data/models/auth_session_model.dart';
import 'package:stay_alive/features/auth/data/models/auth_user_model.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart'
    show OAuthSignInProvider;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

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
    required OAuthSignInProvider provider,
  });

  Future<AuthUserModel> getCurrentUser();

  Future<AuthSessionModel?> getCurrentSession();

  /// Dev-only: creates a real Supabase anonymous session (throwaway user).
  Future<AuthUserModel> createAnonymousSession();

  Future<AuthUserModel> updatePreferences({
    required Map<String, dynamic> preferences,
  });

  Future<void> logout();

  Future<void> deleteAccount();
}

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource({
    required supabase.SupabaseClient client,
    required supabase.GoTrueClient auth,
    required supabase.FunctionsClient functions,
    required AppLogger logger,
  })  : _client = client,
        _auth = auth,
        _functions = functions,
        _logger = logger;

  final supabase.SupabaseClient _client;
  final supabase.GoTrueClient _auth;
  final supabase.FunctionsClient _functions;
  final AppLogger _logger;

  /// Deep link the OAuth browser flow returns to. Must be listed in Supabase
  /// auth redirect URLs and registered as a URL scheme on both platforms.
  static const String _oauthRedirectUri = 'stayalive://login-callback';

  /// The browser flow has no cancel signal; give the user this long to finish.
  static const Duration _oauthTimeout = Duration(minutes: 2);

  @override
  Future<AuthSessionModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final supabase.AuthResponse response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    _logger.info(
      'Logged in with email',
      data: <String, Object?>{'email': email},
    );
    final supabase.Session session = response.session!;
    await _ensureProfileRow(AuthUserModel.fromSupabase(session.user));
    return AuthSessionModel.fromSupabase(session);
  }

  @override
  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final supabase.AuthResponse response = await _auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{'name': name},
    );
    _logger.info(
      'Created account with email',
      data: <String, Object?>{'email': email},
    );

    // The app expects instant login after sign-up. A null session means email
    // confirmations are enabled on the Supabase project — a misconfiguration
    // for this app, surfaced loudly instead of a broken logged-out state.
    final supabase.Session? session = response.session;
    if (session == null) {
      throw const supabase.AuthException(
        'Sign-up returned no session. Disable email confirmations for this '
        'project (Supabase Dashboard → Authentication → Email).',
      );
    }

    final AuthUserModel authUser = AuthUserModel.fromSupabase(session.user);
    await _ensureProfileRow(authUser);
    return authUser;
  }

  @override
  Future<AuthSessionModel> loginWithOAuth({
    required OAuthSignInProvider provider,
  }) async {
    final supabase.OAuthProvider oauthProvider = switch (provider) {
      OAuthSignInProvider.google => supabase.OAuthProvider.google,
      OAuthSignInProvider.apple => supabase.OAuthProvider.apple,
    };

    // signInWithOAuth completes when the browser LAUNCHES, not when the user
    // finishes. The session lands later via the deep link, so subscribe to
    // auth events before launching and wait for signedIn.
    final Future<supabase.AuthState> signedIn = _auth.onAuthStateChange
        .firstWhere(
          (supabase.AuthState state) =>
              state.event == supabase.AuthChangeEvent.signedIn &&
              state.session != null,
        )
        .timeout(_oauthTimeout);

    final bool launched = await _auth.signInWithOAuth(
      oauthProvider,
      redirectTo: _oauthRedirectUri,
      authScreenLaunchMode: supabase.LaunchMode.externalApplication,
    );
    if (!launched) {
      throw supabase.AuthException(
        'Could not launch ${provider.name} sign-in.',
      );
    }

    final supabase.Session session;
    try {
      session = (await signedIn).session!;
    } on TimeoutException {
      throw const supabase.AuthException(
        'OAuth sign-in was cancelled or timed out.',
      );
    }

    _logger.info(
      'Logged in with OAuth',
      data: <String, Object?>{'provider': provider.name},
    );
    await _ensureProfileRow(AuthUserModel.fromSupabase(session.user));
    return AuthSessionModel.fromSupabase(session);
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    final supabase.User? user = _auth.currentUser;
    if (user == null) {
      throw const supabase.AuthException(
        'No active session.',
        statusCode: '401',
      );
    }
    final AuthUserModel authUser = AuthUserModel.fromSupabase(user);
    try {
      await _ensureProfileRow(authUser);
    } on supabase.PostgrestException catch (exception) {
      _logger.warning(
        'Continuing without profiles table row',
        data: <String, Object?>{'reason': exception.message},
      );
    }
    return authUser;
  }

  @override
  Future<AuthSessionModel?> getCurrentSession() async {
    final supabase.Session? session = _auth.currentSession;
    if (session == null) {
      return null;
    }
    return AuthSessionModel.fromSupabase(session);
  }

  @override
  Future<AuthUserModel> createAnonymousSession() async {
    await _auth.signInAnonymously();
    _logger.info('Created anonymous session (dev mock login)');
    // Land the throwaway user straight on the home shell.
    final supabase.UserResponse updated = await _auth.updateUser(
      supabase.UserAttributes(
        data: <String, dynamic>{'onboardingCompleted': true},
      ),
    );
    final AuthUserModel authUser = AuthUserModel.fromSupabase(updated.user!);
    await _ensureProfileRow(authUser);
    return authUser;
  }

  @override
  Future<AuthUserModel> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    // GoTrue shallow-merges user_metadata, so passing only the delta matches
    // the old read-merge-write behaviour.
    final supabase.UserResponse response = await _auth.updateUser(
      supabase.UserAttributes(data: preferences),
    );
    final AuthUserModel authUser = AuthUserModel.fromSupabase(response.user!);
    await _ensureProfileRow(authUser);
    if (preferences.containsKey('onboardingCompleted')) {
      await _syncOnboardingToProfileRow(authUser, preferences);
    }
    _logger.info(
      'Updated user preferences',
      data: <String, Object?>{'userId': authUser.id},
    );
    return authUser;
  }

  @override
  Future<void> logout() {
    _logger.info('Logging out active session');
    return _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final supabase.User? user = _auth.currentUser;
    if (user == null) {
      throw const supabase.AuthException(
        'No active session.',
        statusCode: '401',
      );
    }
    _logger.info(
      'Deleting account and user data',
      data: <String, Object?>{'userId': user.id},
    );

    // The delete_user edge function verifies the caller's JWT and deletes the
    // auth record; every row in every table follows via ON DELETE CASCADE.
    //
    // Best-effort: a failure here must NOT abort account deletion — the user
    // must still be signed out locally. Failures are logged (→ Sentry) so a
    // stale account can be reconciled server-side.
    try {
      await _functions.invoke(SupabaseFunctions.deleteUser);
      _logger.info(
        'Deleted server-side auth record (rows removed via cascade)',
        data: <String, Object?>{'userId': user.id},
      );
    } on Exception catch (exception) {
      _logger.error(
        'Server-side account deletion failed; account may be orphaned',
        error: exception,
        data: <String, Object?>{'userId': user.id},
      );
    }

    // Global scope mirrors the old deleteSessions() (all devices). GoTrue
    // clears the local session before the network call and already tolerates
    // 401/403/404 for users that no longer exist; anything else is logged —
    // never thrown, so the local sign-out always stands.
    try {
      await _auth.signOut(scope: supabase.SignOutScope.global);
    } on supabase.AuthException catch (exception) {
      _logger.warning(
        'Global sign-out after account deletion reported an error',
        data: <String, Object?>{'reason': exception.message},
      );
    }
  }

  /// Ensure-exists for the caller's `profiles` row: insert with defaults,
  /// silently keep the existing row (`ON CONFLICT DO NOTHING`).
  Future<void> _ensureProfileRow(AuthUserModel user) async {
    await _client.from(SupabaseTables.profiles).upsert(
          _profileRowForCreate(user),
          onConflict: 'id',
          ignoreDuplicates: true,
        );
  }

  /// Row payload for `profiles`. Primary key is the auth user id;
  /// created_at/updated_at come from column defaults.
  Map<String, dynamic> _profileRowForCreate(AuthUserModel user) {
    return <String, dynamic>{
      'id': user.id,
      'email': _emailForProfileRow(user),
      'name': _displayNameFor(user),
      'onboarding_completed': false,
      'units_preference': 'metric',
      'locale': 'en',
    };
  }

  /// Best-effort mirror of onboarding into the profile row.
  /// Auth user_metadata remains the source of truth.
  Future<void> _syncOnboardingToProfileRow(
    AuthUserModel user,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _client
          .from(SupabaseTables.profiles)
          .update(<String, dynamic>{
            'onboarding_completed': preferences['onboardingCompleted'] == true,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);
    } on supabase.PostgrestException catch (exception) {
      _logger.warning(
        'Skipped onboarding sync to profiles table',
        data: <String, Object?>{'reason': exception.message},
      );
    }
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

  /// Anonymous/guest Supabase users have no email; the `profiles` table
  /// requires one, so we store a stable synthetic address keyed by user id.
  String _emailForProfileRow(AuthUserModel user) {
    final String email = user.email.trim();
    if (email.isNotEmpty) {
      return email;
    }
    return '${user.id}@guest.stayalive.local';
  }
}
