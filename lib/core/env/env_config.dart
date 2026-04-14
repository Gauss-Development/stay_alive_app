import 'package:equatable/equatable.dart';

class EnvConfig extends Equatable {
  const EnvConfig({
    required this.appwriteEndpoint,
    required this.appwriteProjectId,
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

  static EnvConfig fromEnvironment() {
    const String endpoint = String.fromEnvironment(
      'APPWRITE_ENDPOINT',
      defaultValue: 'https://fra.cloud.appwrite.io/v1',
    );
    const String projectId = String.fromEnvironment(
      'APPWRITE_PROJECT_ID',
      defaultValue: 'daily-dozen-dev-project-id',
    );
    const String databaseId = String.fromEnvironment(
      'APPWRITE_DATABASE_ID',
      defaultValue: 'daily_dozen_db',
    );
    const String usersCollectionId = String.fromEnvironment(
      'APPWRITE_USERS_COLLECTION_ID',
      defaultValue: 'users',
    );
    const String categoryDefinitionsCollectionId = String.fromEnvironment(
      'APPWRITE_CATEGORY_DEFINITIONS_COLLECTION_ID',
      defaultValue: 'category_definitions',
    );
    const String dailyLogsCollectionId = String.fromEnvironment(
      'APPWRITE_DAILY_LOGS_COLLECTION_ID',
      defaultValue: 'daily_logs',
    );
    const String dailyLogItemsCollectionId = String.fromEnvironment(
      'APPWRITE_DAILY_LOG_ITEMS_COLLECTION_ID',
      defaultValue: 'daily_log_items',
    );
    const String subscriptionsCollectionId = String.fromEnvironment(
      'APPWRITE_SUBSCRIPTIONS_COLLECTION_ID',
      defaultValue: 'subscriptions',
    );
    const String analyticsEventsCollectionId = String.fromEnvironment(
      'APPWRITE_ANALYTICS_EVENTS_COLLECTION_ID',
      defaultValue: 'analytics_events',
    );
    const String educationalContentCollectionId = String.fromEnvironment(
      'APPWRITE_EDUCATIONAL_CONTENT_COLLECTION_ID',
      defaultValue: 'educational_content',
    );
    const String avatarsBucketId = String.fromEnvironment(
      'APPWRITE_AVATARS_BUCKET_ID',
      defaultValue: 'avatars',
    );
    const String userUploadsBucketId = String.fromEnvironment(
      'APPWRITE_USER_UPLOADS_BUCKET_ID',
      defaultValue: 'user_uploads',
    );
    const String contentAssetsBucketId = String.fromEnvironment(
      'APPWRITE_CONTENT_ASSETS_BUCKET_ID',
      defaultValue: 'content_assets',
    );
    const String allowSelfSignedRaw = String.fromEnvironment(
      'APPWRITE_SELF_SIGNED',
      defaultValue: 'false',
    );
    const bool allowSelfSigned = allowSelfSignedRaw == 'true';

    return const EnvConfig(
      appwriteEndpoint: endpoint,
      appwriteProjectId: projectId,
      appwriteDatabaseId: databaseId,
      usersCollectionId: usersCollectionId,
      categoryDefinitionsCollectionId: categoryDefinitionsCollectionId,
      dailyLogsCollectionId: dailyLogsCollectionId,
      dailyLogItemsCollectionId: dailyLogItemsCollectionId,
      subscriptionsCollectionId: subscriptionsCollectionId,
      analyticsEventsCollectionId: analyticsEventsCollectionId,
      educationalContentCollectionId: educationalContentCollectionId,
      avatarsBucketId: avatarsBucketId,
      userUploadsBucketId: userUploadsBucketId,
      contentAssetsBucketId: contentAssetsBucketId,
      allowSelfSigned: allowSelfSigned,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        appwriteEndpoint,
        appwriteProjectId,
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
