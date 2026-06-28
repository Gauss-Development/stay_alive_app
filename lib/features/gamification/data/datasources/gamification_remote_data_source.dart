import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/gamification/data/models/user_game_profile_model.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';

abstract class GamificationRemoteDataSource {
  Future<UserGameProfileModel> reconcileProgress();
}

class AppwriteGamificationRemoteDataSource
    implements GamificationRemoteDataSource {
  AppwriteGamificationRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
    GamificationEngine? engine,
  })  : _account = account,
        _databases = databases,
        _envConfig = envConfig,
        _engine = engine ?? const GamificationEngine();

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;
  final GamificationEngine _engine;

  @override
  Future<UserGameProfileModel> reconcileProgress() async {
    final appwrite_models.User user = await _account.get();
    final List<DailyLogModel> logs = await _loadLogsWithItems(user.$id);
    final UserGameProfile profile = _engine.reconcile(
      userId: user.$id,
      logs: logs,
    );
    final UserGameProfileModel model = UserGameProfileModel.fromProfile(profile);
    await _upsertProfile(model);
    await _upsertBadgeEvents(model);
    return model;
  }

  Future<List<DailyLogModel>> _loadLogsWithItems(String userId) async {
    final appwrite_models.DocumentList documents = await _databases
        .listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogsCollectionId,
      queries: <String>[
        Query.equal('user_id', userId),
        Query.orderAsc('log_date'),
        Query.limit(365),
      ],
    );

    final Map<String, List<DailyLogItemModel>> itemsByLogId =
        await _loadItemsByLogId(userId);

    return documents.documents
        .map(
          (appwrite_models.Document document) {
            final String logId =
                document.data['log_id']?.toString() ?? document.$id;
            return DailyLogModel.fromDocument(
              document: document,
              items: itemsByLogId[logId] ?? const <DailyLogItemModel>[],
            );
          },
        )
        .toList(growable: false);
  }

  Future<Map<String, List<DailyLogItemModel>>> _loadItemsByLogId(
    String userId,
  ) async {
    final appwrite_models.DocumentList itemDocuments =
        await _databases.listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogItemsCollectionId,
      queries: <String>[
        Query.equal('user_id', userId),
        Query.limit(5000),
      ],
    );

    final Map<String, List<DailyLogItemModel>> itemsByLogId =
        <String, List<DailyLogItemModel>>{};
    for (final appwrite_models.Document document in itemDocuments.documents) {
      final Map<String, dynamic> data = document.data;
      final String logId = data['log_id']?.toString() ?? '';
      if (logId.isEmpty) {
        continue;
      }
      itemsByLogId.putIfAbsent(logId, () => <DailyLogItemModel>[]).add(
            DailyLogItemModel.fromDocumentWithoutCategory(document),
          );
    }
    return itemsByLogId;
  }

  Future<void> _upsertProfile(UserGameProfileModel profile) async {
    final String now = DateTime.now().toUtc().toIso8601String();
    final Map<String, dynamic> data = profile.toDocumentData(now: now);
    try {
      await _databases.updateDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationProfilesCollectionId,
        documentId: profile.userId,
        data: data,
      );
    } on AppwriteException catch (exception) {
      if (exception.code != 404) {
        rethrow;
      }
      await _databases.createDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationProfilesCollectionId,
        documentId: profile.userId,
        data: <String, dynamic>{
          ...data,
          'created_at': now,
        },
        permissions: <String>[
          Permission.read(Role.user(profile.userId)),
          Permission.update(Role.user(profile.userId)),
          Permission.delete(Role.user(profile.userId)),
        ],
      );
    }
  }

  Future<void> _upsertBadgeEvents(UserGameProfileModel profile) async {
    for (final EarnedBadge badge in profile.earnedBadges) {
      final String eventType = badge.id.name;
      final appwrite_models.DocumentList existing = await _databases
          .listDocuments(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationEventsCollectionId,
        queries: <String>[
          Query.equal('user_id', profile.userId),
          Query.equal('event_type', eventType),
          Query.limit(1),
        ],
      );
      if (existing.documents.isNotEmpty) {
        continue;
      }

      try {
        final String documentId = ID.unique();
        await _databases.createDocument(
          databaseId: _envConfig.appwriteDatabaseId,
          collectionId: _envConfig.gamificationEventsCollectionId,
          documentId: documentId,
          data: <String, dynamic>{
            'event_id': documentId,
            'user_id': profile.userId,
            'event_type': eventType,
            'xp_delta':
                GamificationEngine.badgeXpBonuses[badge.id] ?? 0,
            'log_date': badge.earnedAt.toIso8601String().substring(0, 10),
            'metadata_json': jsonEncode(<String, Object?>{
              'level': profile.currentLevel.level,
              'xp': profile.totalXp,
              'badge_id': badge.id.name,
            }),
            'created_at': badge.earnedAt.toUtc().toIso8601String(),
          },
          permissions: <String>[Permission.read(Role.user(profile.userId))],
        );
      } on AppwriteException catch (exception) {
        if (exception.code != 409) {
          rethrow;
        }
      }
    }
  }
}
