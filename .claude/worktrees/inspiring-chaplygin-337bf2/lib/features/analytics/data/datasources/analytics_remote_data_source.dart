import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/analytics/domain/entities/analytics_event.dart';

abstract class AnalyticsRemoteDataSource {
  Future<void> trackEvent(AnalyticsEvent event);
}

class AppwriteAnalyticsRemoteDataSource implements AnalyticsRemoteDataSource {
  AppwriteAnalyticsRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
  })  : _account = account,
        _databases = databases,
        _envConfig = envConfig;

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    String? userId;
    try {
      final appwrite_models.User user = await _account.get();
      userId = user.$id;
    } on AppwriteException {
      userId = null;
    }

    await _databases.createDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.analyticsEventsCollectionId,
      documentId: ID.unique(),
      data: <String, dynamic>{
        'event_id': ID.unique(),
        'user_id': userId ?? '',
        'event_name': event.name,
        'screen_name': event.screenName ?? '',
        'metadata_json': jsonEncode(event.metadata),
        'created_at': event.createdAt.toUtc().toIso8601String(),
      },
      permissions: userId == null
          ? null
          : <String>[
              Permission.read(Role.user(userId)),
              Permission.update(Role.user(userId)),
              Permission.delete(Role.user(userId)),
            ],
    );
  }
}
