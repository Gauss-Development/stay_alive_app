import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_overview_model.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_xp_event_model.dart';
import 'package:stay_alive/features/gamification/data/models/user_game_profile_model.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_overview_builder.dart';

abstract class GamificationRemoteDataSource {
  Future<GamificationOverviewModel> reconcileOverview();
}

class AppwriteGamificationRemoteDataSource
    implements GamificationRemoteDataSource {
  AppwriteGamificationRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
    GamificationEngine? engine,
    GamificationOverviewBuilder? overviewBuilder,
  })  : _account = account,
        _databases = databases,
        _envConfig = envConfig,
        _overviewBuilder =
            overviewBuilder ?? GamificationOverviewBuilder(engine: engine);

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;
  final GamificationOverviewBuilder _overviewBuilder;

  @override
  Future<GamificationOverviewModel> reconcileOverview() async {
    final appwrite_models.User user = await _account.get();
    final List<DailyLogModel> logs = await _loadLogsWithItems(user.$id);
    final List<GamificationXpEventModel> persistedEvents =
        await _fetchXpEvents(user.$id);

    final GamificationOverview overview = _overviewBuilder.build(
      userId: user.$id,
      logs: logs,
      persistedEvents: persistedEvents,
    );

    final UserGameProfileModel profileModel =
        UserGameProfileModel.fromProfile(overview.profile);
    await _upsertProfile(profileModel);
    await _upsertBadgeEvents(profileModel);
    await _upsertChallengeEvent(
      userId: user.$id,
      challenge: overview.dailyChallenge,
      profile: overview.profile,
      persistedEvents: persistedEvents,
    );

    final List<GamificationXpEventModel> refreshedEvents =
        await _fetchXpEvents(user.$id);

    return GamificationOverviewModel(
      profile: overview.profile,
      dailyChallenge: overview.dailyChallenge,
      categoryMastery: overview.categoryMastery,
      recentXpEvents: refreshedEvents,
    );
  }

  Future<List<GamificationXpEventModel>> _fetchXpEvents(String userId) async {
    final appwrite_models.DocumentList documents = await _databases
        .listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.gamificationEventsCollectionId,
      queries: <String>[
        Query.equal('user_id', userId),
        Query.orderDesc('\$createdAt'),
        Query.limit(50),
      ],
    );

    return documents.documents
        .map(GamificationXpEventModel.fromDocument)
        .toList(growable: false);
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
      await _createEventIfMissing(
        userId: profile.userId,
        eventType: badge.id.name,
        xpDelta: GamificationEngine.badgeXpBonuses[badge.id] ?? 0,
        logDate: badge.earnedAt.toIso8601String().substring(0, 10),
        createdAt: badge.earnedAt.toUtc(),
        metadata: <String, Object?>{
          'badge_id': badge.id.name,
          'level': profile.currentLevel.level,
          'xp': profile.totalXp,
        },
      );
    }
  }

  Future<void> _upsertChallengeEvent({
    required String userId,
    required GamificationChallenge challenge,
    required UserGameProfile profile,
    required List<GamificationXpEvent> persistedEvents,
  }) async {
    if (!challenge.isCompleted) {
      return;
    }

    final bool exists = persistedEvents.any(
      (GamificationXpEvent event) =>
          event.eventType == 'challenge_completed' &&
          event.logDate == challenge.dateKey,
    );
    if (exists) {
      return;
    }

    await _createEventIfMissing(
      userId: userId,
      eventType: 'challenge_completed',
      xpDelta: challenge.xpReward,
      logDate: challenge.dateKey,
      createdAt: DateTime.now().toUtc(),
      metadata: <String, Object?>{
        'challenge_id': challenge.id,
        'challenge_title': challenge.title,
        'level': profile.currentLevel.level,
        'xp': profile.totalXp,
      },
    );
  }

  Future<void> _createEventIfMissing({
    required String userId,
    required String eventType,
    required int xpDelta,
    required String logDate,
    required DateTime createdAt,
    required Map<String, Object?> metadata,
  }) async {
    final appwrite_models.DocumentList existing = await _databases
        .listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.gamificationEventsCollectionId,
      queries: <String>[
        Query.equal('user_id', userId),
        Query.equal('event_type', eventType),
        Query.equal('log_date', logDate),
        Query.limit(1),
      ],
    );
    if (existing.documents.isNotEmpty) {
      return;
    }

    try {
      final String documentId = ID.unique();
      await _databases.createDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationEventsCollectionId,
        documentId: documentId,
        data: <String, dynamic>{
          'event_id': documentId,
          'user_id': userId,
          'event_type': eventType,
          'xp_delta': xpDelta,
          'log_date': logDate,
          'metadata_json': jsonEncode(metadata),
          'created_at': createdAt.toIso8601String(),
        },
        permissions: <String>[Permission.read(Role.user(userId))],
      );
    } on AppwriteException catch (exception) {
      if (exception.code != 409) {
        rethrow;
      }
    }
  }
}
