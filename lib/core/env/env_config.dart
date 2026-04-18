import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Unified Appwrite / app configuration.
///
/// Values are resolved in order:
/// 1. `--dart-define=KEY=value` (CI / flavors)
/// 2. `assets/env/app.env` (optional; gitignored — use for secrets / local overrides)
/// 3. `assets/env/app.env.example` (committed defaults) if .env was missing or empty
/// 4. Hardcoded fallbacks in this file
class EnvConfig extends Equatable {
  const EnvConfig({
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
    required this.avatarsBucketId,
    required this.userUploadsBucketId,
    required this.contentAssetsBucketId,
    required this.allowSelfSigned,
  });

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
  final String avatarsBucketId;
  final String userUploadsBucketId;
  final String contentAssetsBucketId;
  final bool allowSelfSigned;

  /// Call after [loadEnvFiles] has run in [main].
  factory EnvConfig.fromEnv() {
    return EnvConfig(
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
        avatarsBucketId,
        userUploadsBucketId,
        contentAssetsBucketId,
        allowSelfSigned,
      ];
}
