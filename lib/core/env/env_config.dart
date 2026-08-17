import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Unified Appwrite / app configuration.
///
/// Values are resolved in order:
/// 1. `--dart-define=KEY=value` (CI / flavors)
/// 2. `assets/env/app.env` (optional; gitignored — load via [loadEnvForFlavor])
/// 3. `assets/env/app.dev.env` or `assets/env/app.prod.env` (per [AppFlavor])
/// 4. `assets/env/app.env.example` (committed defaults)
class EnvConfig extends Equatable {
  const EnvConfig({
    required this.appFlavor,
    required this.appwriteEndpoint,
    required this.appwriteProjectId,
    required this.appwriteDatabaseId,
    required this.usersCollectionId,
    required this.categoryDefinitionsCollectionId,
    required this.dailyLogsCollectionId,
    required this.dailyLogItemsCollectionId,
    required this.subscriptionsCollectionId,
    required this.analyticsEventsCollectionId,
    required this.gamificationProfilesCollectionId,
    required this.gamificationEventsCollectionId,
    required this.deleteUserFunctionId,
    required this.aiCoachFunctionId,
    required this.widgetAppGroupId,
    required this.revenueCatAndroidApiKey,
    required this.revenueCatIosApiKey,
    required this.revenueCatEntitlementId,
    required this.revenueCatOfferingId,
    required this.allowSelfSigned,
    required this.sentryDsn,
    required this.sentryEnvironment,
  });

  final AppFlavor appFlavor;
  final String appwriteEndpoint;
  final String appwriteProjectId;
  final String appwriteDatabaseId;
  final String usersCollectionId;
  final String categoryDefinitionsCollectionId;
  final String dailyLogsCollectionId;
  final String dailyLogItemsCollectionId;
  final String subscriptionsCollectionId;
  final String analyticsEventsCollectionId;
  final String gamificationProfilesCollectionId;
  final String gamificationEventsCollectionId;

  /// Appwrite Function id that deletes the caller's auth record server-side
  /// (`functions/delete_user`). Empty in dev/local → auth record is not removed
  /// on account deletion; must be set for store-compliant deletion.
  final String deleteUserFunctionId;

  /// Appwrite Function id for AI coach (`functions/ai_coach`). Empty → local
  /// heuristic fallback in the Flutter client.
  final String aiCoachFunctionId;

  final String widgetAppGroupId;
  final String revenueCatAndroidApiKey;
  final String revenueCatIosApiKey;
  final String revenueCatEntitlementId;
  final String revenueCatOfferingId;
  final bool allowSelfSigned;
  final String sentryDsn;
  final String sentryEnvironment;

  /// Call after [loadEnvForFlavor] has run in [bootstrap].
  factory EnvConfig.fromEnv(AppFlavor flavor) {
    return EnvConfig(
      appFlavor: flavor,
      appwriteEndpoint: _str(
        'APPWRITE_ENDPOINT',
        'https://nyc.cloud.appwrite.io/v1',
      ),
      appwriteProjectId: _str('APPWRITE_PROJECT_ID', '6a53570100147968d1f6'),
      appwriteDatabaseId: _str('APPWRITE_DATABASE_ID', 'stay_alive_v1'),
      usersCollectionId: _str('APPWRITE_USERS_COLLECTION_ID', 'users'),
      categoryDefinitionsCollectionId: _str(
        'APPWRITE_CATEGORY_DEFINITIONS_COLLECTION_ID',
        'category_definitions',
      ),
      dailyLogsCollectionId: _str(
        'APPWRITE_DAILY_LOGS_COLLECTION_ID',
        'daily_logs',
      ),
      dailyLogItemsCollectionId: _str(
        'APPWRITE_DAILY_LOG_ITEMS_COLLECTION_ID',
        'daily_log_items',
      ),
      subscriptionsCollectionId: _str(
        'APPWRITE_SUBSCRIPTIONS_COLLECTION_ID',
        'subscriptions',
      ),
      analyticsEventsCollectionId: _str(
        'APPWRITE_ANALYTICS_EVENTS_COLLECTION_ID',
        'analytics_events',
      ),
      gamificationProfilesCollectionId: _str(
        'APPWRITE_GAMIFICATION_PROFILES_COLLECTION_ID',
        'gamification_profiles',
      ),
      gamificationEventsCollectionId: _str(
        'APPWRITE_GAMIFICATION_EVENTS_COLLECTION_ID',
        'gamification_events',
      ),
      deleteUserFunctionId: _str('APPWRITE_DELETE_USER_FUNCTION_ID', ''),
      aiCoachFunctionId: _str('APPWRITE_AI_COACH_FUNCTION_ID', ''),
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
      allowSelfSigned: _bool('APPWRITE_SELF_SIGNED', false),
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

  static bool _bool(String key, bool fallback) {
    final String fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine == 'true';
    }
    if (dotenv.isInitialized) {
      final String? v = dotenv.env[key];
      if (v != null && v.trim().isNotEmpty) {
        return v.trim().toLowerCase() == 'true';
      }
    }
    return fallback;
  }

  @override
  List<Object?> get props => <Object?>[
        appFlavor,
        appwriteEndpoint,
        appwriteProjectId,
        appwriteDatabaseId,
        usersCollectionId,
        categoryDefinitionsCollectionId,
        dailyLogsCollectionId,
        dailyLogItemsCollectionId,
        subscriptionsCollectionId,
        analyticsEventsCollectionId,
        gamificationProfilesCollectionId,
        gamificationEventsCollectionId,
        deleteUserFunctionId,
        aiCoachFunctionId,
        widgetAppGroupId,
        revenueCatAndroidApiKey,
        revenueCatIosApiKey,
        revenueCatEntitlementId,
        revenueCatOfferingId,
        allowSelfSigned,
        sentryDsn,
        sentryEnvironment,
      ];
}
