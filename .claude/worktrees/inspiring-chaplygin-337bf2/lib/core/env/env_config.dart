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
    required this.appwriteProjectName,
    required this.appwriteDatabaseId,
    required this.usersCollectionId,
    required this.categoryDefinitionsCollectionId,
    required this.dailyLogsCollectionId,
    required this.dailyLogItemsCollectionId,
    required this.subscriptionsCollectionId,
    required this.analyticsEventsCollectionId,
    required this.educationalContentCollectionId,
    required this.gamificationProfilesCollectionId,
    required this.gamificationEventsCollectionId,
    required this.widgetAppGroupId,
    required this.revenueCatAndroidApiKey,
    required this.revenueCatIosApiKey,
    required this.revenueCatEntitlementId,
    required this.revenueCatOfferingId,
    required this.avatarsBucketId,
    required this.userUploadsBucketId,
    required this.contentAssetsBucketId,
    required this.allowSelfSigned,
    required this.revenueCatApiKeyIos,
    required this.revenueCatApiKeyAndroid,
    required this.sentryDsn,
    required this.sentryEnvironment,
  });

  final AppFlavor appFlavor;
  final String appwriteEndpoint;
  final String appwriteProjectId;
  final String appwriteProjectName;
  final String appwriteDatabaseId;
  final String usersCollectionId;
  final String categoryDefinitionsCollectionId;
  final String dailyLogsCollectionId;
  final String dailyLogItemsCollectionId;
  final String subscriptionsCollectionId;
  final String analyticsEventsCollectionId;
  final String educationalContentCollectionId;
  final String gamificationProfilesCollectionId;
  final String gamificationEventsCollectionId;
  final String widgetAppGroupId;
  final String revenueCatAndroidApiKey;
  final String revenueCatIosApiKey;
  final String revenueCatEntitlementId;
  final String revenueCatOfferingId;
  final String avatarsBucketId;
  final String userUploadsBucketId;
  final String contentAssetsBucketId;
  final bool allowSelfSigned;
  final String revenueCatApiKeyIos;
  final String revenueCatApiKeyAndroid;
  final String sentryDsn;
  final String sentryEnvironment;

  /// Call after [loadEnvForFlavor] has run in [bootstrap].
  factory EnvConfig.fromEnv(AppFlavor flavor) {
    return EnvConfig(
      appFlavor: flavor,
      appwriteEndpoint: _str(
        'APPWRITE_ENDPOINT',
        'https://sfo.cloud.appwrite.io/v1',
      ),
      appwriteProjectId: _str(
        'APPWRITE_PROJECT_ID',
        '69de16de001dfb5c1e5d',
      ),
      appwriteProjectName: _str(
        'APPWRITE_PROJECT_NAME',
        'Stay Alive',
      ),
      appwriteDatabaseId: _str(
        'APPWRITE_DATABASE_ID',
        'daily_dozen_db',
      ),
      usersCollectionId: _str(
        'APPWRITE_USERS_COLLECTION_ID',
        'users',
      ),
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
      educationalContentCollectionId: _str(
        'APPWRITE_EDUCATIONAL_CONTENT_COLLECTION_ID',
        'educational_content',
      ),
      gamificationProfilesCollectionId: _str(
        'APPWRITE_GAMIFICATION_PROFILES_COLLECTION_ID',
        'gamification_profiles',
      ),
      gamificationEventsCollectionId: _str(
        'APPWRITE_GAMIFICATION_EVENTS_COLLECTION_ID',
        'gamification_events',
      ),
      widgetAppGroupId: _str(
        'DAILY_GOAL_WIDGET_APP_GROUP_ID',
        'group.com.gaussdev.stayalive',
      ),
      revenueCatAndroidApiKey: _str(
        'REVENUECAT_ANDROID_API_KEY',
        'test_xsTTIBRKlCVdXpltnlImbcuZhVt',
      ),
      revenueCatIosApiKey: _str(
        'REVENUECAT_IOS_API_KEY',
        'test_xsTTIBRKlCVdXpltnlImbcuZhVt',
      ),
      revenueCatEntitlementId: _str(
        'REVENUECAT_ENTITLEMENT_ID',
        'premium',
      ),
      revenueCatOfferingId: _str(
        'REVENUECAT_OFFERING_ID',
        'default',
      ),
      avatarsBucketId: _str(
        'APPWRITE_AVATARS_BUCKET_ID',
        'avatars',
      ),
      userUploadsBucketId: _str(
        'APPWRITE_USER_UPLOADS_BUCKET_ID',
        'user_uploads',
      ),
      contentAssetsBucketId: _str(
        'APPWRITE_CONTENT_ASSETS_BUCKET_ID',
        'content_assets',
      ),
      allowSelfSigned: _bool(
        'APPWRITE_SELF_SIGNED',
        false,
      ),
      revenueCatApiKeyIos: _str(
        'REVENUECAT_API_KEY_IOS',
        '',
      ),
      revenueCatApiKeyAndroid: _str(
        'REVENUECAT_API_KEY_ANDROID',
        '',
      ),
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
        appwriteProjectName,
        appwriteDatabaseId,
        usersCollectionId,
        categoryDefinitionsCollectionId,
        dailyLogsCollectionId,
        dailyLogItemsCollectionId,
        subscriptionsCollectionId,
        analyticsEventsCollectionId,
        educationalContentCollectionId,
        gamificationProfilesCollectionId,
        gamificationEventsCollectionId,
        widgetAppGroupId,
        revenueCatAndroidApiKey,
        revenueCatIosApiKey,
        revenueCatEntitlementId,
        revenueCatOfferingId,
        avatarsBucketId,
        userUploadsBucketId,
        contentAssetsBucketId,
        allowSelfSigned,
        revenueCatApiKeyIos,
        revenueCatApiKeyAndroid,
        sentryDsn,
        sentryEnvironment,
      ];
}
