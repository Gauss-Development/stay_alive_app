class AppwriteConstants {
  const AppwriteConstants._();

  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://cloud.appwrite.io/v1',
  );

  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: 'YOUR_APPWRITE_PROJECT_ID',
  );

  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: 'daily_dozen_db',
  );

  static const String usersCollectionId = String.fromEnvironment(
    'APPWRITE_USERS_COLLECTION_ID',
    defaultValue: 'users',
  );

  static const String categoryDefinitionsCollectionId = String.fromEnvironment(
    'APPWRITE_CATEGORY_DEFINITIONS_COLLECTION_ID',
    defaultValue: 'category_definitions',
  );

  static const String dailyLogsCollectionId = String.fromEnvironment(
    'APPWRITE_DAILY_LOGS_COLLECTION_ID',
    defaultValue: 'daily_logs',
  );

  static const String dailyLogItemsCollectionId = String.fromEnvironment(
    'APPWRITE_DAILY_LOG_ITEMS_COLLECTION_ID',
    defaultValue: 'daily_log_items',
  );

  static const String analyticsEventsCollectionId = String.fromEnvironment(
    'APPWRITE_ANALYTICS_EVENTS_COLLECTION_ID',
    defaultValue: 'analytics_events',
  );

  static const String subscriptionsCollectionId = String.fromEnvironment(
    'APPWRITE_SUBSCRIPTIONS_COLLECTION_ID',
    defaultValue: 'subscriptions',
  );

  static const String educationalContentCollectionId = String.fromEnvironment(
    'APPWRITE_EDUCATIONAL_CONTENT_COLLECTION_ID',
    defaultValue: 'educational_content',
  );
}
