import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Unified Supabase / app configuration.
///
/// Values are resolved in order:
/// 1. `--dart-define=KEY=value` (CI / flavors)
/// 2. `assets/env/app.env` (optional; gitignored — load via [loadEnvForFlavor])
/// 3. `assets/env/app.dev.env` or `assets/env/app.prod.env` (per [AppFlavor])
/// 4. `assets/env/app.env.example` (committed defaults)
class EnvConfig extends Equatable {
  const EnvConfig({
    required this.appFlavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.widgetAppGroupId,
    required this.revenueCatAndroidApiKey,
    required this.revenueCatIosApiKey,
    required this.revenueCatEntitlementId,
    required this.revenueCatOfferingId,
    required this.sentryDsn,
    required this.sentryEnvironment,
  });

  final AppFlavor appFlavor;

  /// Supabase project URL. In production this must be injected
  /// (`--dart-define=SUPABASE_URL=...`); the committed fallback points at the
  /// local `supabase start` stack and is refused for prod builds, so a
  /// misconfigured release fails loudly at bootstrap instead of silently
  /// talking to a dev backend.
  final String supabaseUrl;

  /// Supabase publishable (anon) key. Same fail-closed rule as [supabaseUrl];
  /// `sb_publishable_...` keys go in the same variable.
  final String supabaseAnonKey;

  final String widgetAppGroupId;
  final String revenueCatAndroidApiKey;
  final String revenueCatIosApiKey;
  final String revenueCatEntitlementId;
  final String revenueCatOfferingId;
  final String sentryDsn;
  final String sentryEnvironment;

  /// Default anon key of the local `supabase start` stack (public demo JWT,
  /// identical for every local install — not a secret).
  static const String _localAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  /// Call after [loadEnvForFlavor] has run in [bootstrap].
  factory EnvConfig.fromEnv(AppFlavor flavor) {
    return EnvConfig(
      appFlavor: flavor,
      supabaseUrl: _devOnly('SUPABASE_URL', 'http://127.0.0.1:54321', flavor),
      supabaseAnonKey: _devOnly('SUPABASE_ANON_KEY', _localAnonKey, flavor),
      widgetAppGroupId: _str(
        'DAILY_GOAL_WIDGET_APP_GROUP_ID',
        'group.com.gaussdev.stayalive',
      ),
      revenueCatAndroidApiKey: _secret(
        'REVENUECAT_ANDROID_API_KEY',
        'test_xsTTIBRKlCVdXpltnlImbcuZhVt',
        flavor,
      ),
      revenueCatIosApiKey: _secret(
        'REVENUECAT_IOS_API_KEY',
        'test_xsTTIBRKlCVdXpltnlImbcuZhVt',
        flavor,
      ),
      revenueCatEntitlementId: _str(
        'REVENUECAT_ENTITLEMENT_ID',
        'Stay Alive Pro',
      ),
      revenueCatOfferingId: _str('REVENUECAT_OFFERING_ID', 'default'),
      sentryDsn: _str('SENTRY_DSN', ''),
      sentryEnvironment: _str('SENTRY_ENVIRONMENT', flavor.name),
    );
  }

  static String _str(String key, String fallback) {
    final String fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (dotenv.isInitialized) {
      final String? v = dotenv.env[key];
      if (v != null && v.trim().isNotEmpty) {
        return v.trim();
      }
    }
    return fallback;
  }

  /// Resolves a value whose committed fallback is only valid for development.
  ///
  /// Production builds must inject the real value; returning empty makes prod
  /// fail closed (bootstrap throws) instead of silently using the dev backend.
  static String _devOnly(String key, String devFallback, AppFlavor flavor) {
    return _str(key, flavor.isProduction ? '' : devFallback);
  }

  /// Resolves a credential, refusing sandbox placeholders in production.
  ///
  /// RevenueCat sandbox keys are prefixed `test_`, and the committed fallbacks
  /// are exactly that. Being non-empty, they slip past the data source's
  /// `apiKey.isEmpty` guard, so a production build with no injected secret
  /// would configure RevenueCat against the sandbox and mis-report entitlements
  /// while looking like working code. Returning empty makes it fail closed:
  /// subscriptions stay inactive and the data source logs why.
  static String _secret(String key, String fallback, AppFlavor flavor) {
    final String value = _str(key, fallback);
    if (flavor.isProduction && value.startsWith('test_')) {
      return '';
    }
    return value;
  }

  @override
  List<Object?> get props => <Object?>[
        appFlavor,
        supabaseUrl,
        supabaseAnonKey,
        widgetAppGroupId,
        revenueCatAndroidApiKey,
        revenueCatIosApiKey,
        revenueCatEntitlementId,
        revenueCatOfferingId,
        sentryDsn,
        sentryEnvironment,
      ];
}
