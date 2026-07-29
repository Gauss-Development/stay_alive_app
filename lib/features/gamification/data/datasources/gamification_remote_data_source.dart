import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/daily_tracker/data/daily_log_document_ids.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
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
  Future<GamificationOverviewModel> reconcileOverview({
    required bool isPremium,
  });

  Future<GamificationOverviewModel> reconcileTodayOverview({
    required DailyLog todayLog,
    required bool isPremium,
  });
}

class AppwriteGamificationRemoteDataSource
    implements GamificationRemoteDataSource {
  AppwriteGamificationRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
    GamificationEngine? engine,
    GamificationOverviewBuilder? overviewBuilder,
  }) : _account = account,
       _databases = databases,
       _envConfig = envConfig,
       _overviewBuilder =
           overviewBuilder ?? GamificationOverviewBuilder(engine: engine);

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;
  final GamificationOverviewBuilder _overviewBuilder;

  static const int _fullReconcileDayWindow = 365;
  static const int _todayReconcileDayWindow = 45;

  @override
  Future<GamificationOverviewModel> reconcileOverview({
    required bool isPremium,
  }) async {
    final appwrite_models.User user = await _account.get();
    final UserGameProfileModel? persistedProfile = await _loadPersistedProfile(
      user.$id,
    );
    final List<DailyLogModel> logs = await _loadLogsWithItems(
      user.$id,
      dayWindow: _fullReconcileDayWindow,
    );
    final List<GamificationXpEventModel> persistedEvents = await _fetchXpEvents(
      user.$id,
    );

    return _buildAndPersist(
      userId: user.$id,
      logs: logs,
      persistedEvents: persistedEvents,
      isPremium: isPremium,
      persistedProfile: persistedProfile,
    );
  }

  @override
  Future<GamificationOverviewModel> reconcileTodayOverview({
    required DailyLog todayLog,
    required bool isPremium,
  }) async {
    final appwrite_models.User user = await _account.get();
    final UserGameProfileModel? persistedProfile = await _loadPersistedProfile(
      user.$id,
    );
    final List<DailyLogModel> logs = await _loadLogsWithItems(
      user.$id,
      dayWindow: _todayReconcileDayWindow,
    );
    final List<DailyLogModel> mergedLogs = _mergeTodayLog(logs, todayLog);
    final List<GamificationXpEventModel> persistedEvents = await _fetchXpEvents(
      user.$id,
    );

    return _buildAndPersist(
      userId: user.$id,
      logs: mergedLogs,
      persistedEvents: persistedEvents,
      isPremium: isPremium,
      persistedProfile: persistedProfile,
    );
  }

  Future<GamificationOverviewModel> _buildAndPersist({
    required String userId,
    required List<DailyLogModel> logs,
    required List<GamificationXpEventModel> persistedEvents,
    required bool isPremium,
    required UserGameProfileModel? persistedProfile,
  }) async {
    final GamificationOverview overview = _overviewBuilder.build(
      userId: userId,
      logs: logs,
      persistedEvents: persistedEvents,
      isPremium: isPremium,
      streakFreezesRemaining: persistedProfile?.streakFreezesRemaining ?? 0,
      streakFreezeUsedDates:
          persistedProfile?.streakFreezeUsedDates ?? const <String>[],
    );

    final UserGameProfileModel profileModel = UserGameProfileModel.fromProfile(
      overview.profile,
    );
    await _upsertProfile(profileModel);
    await _upsertBadgeEvents(profileModel);
    await _upsertChallengeEvent(
      userId: userId,
      challenge: overview.dailyChallenge,
      profile: overview.profile,
      persistedEvents: persistedEvents,
      eventType: 'challenge_completed',
      isPremium: isPremium,
    );
    await _upsertChallengeEvent(
      userId: userId,
      challenge: overview.weeklyChallenge,
      profile: overview.profile,
      persistedEvents: persistedEvents,
      eventType: 'weekly_challenge_completed',
      isPremium: isPremium,
    );
    await _upsertStreakFreezeEvents(
      userId: userId,
      previousProfile: persistedProfile,
      nextProfile: overview.profile,
    );

    final List<GamificationXpEventModel> refreshedEvents = await _fetchXpEvents(
      userId,
    );

    return GamificationOverviewModel(
      profile: overview.profile,
      dailyChallenge: overview.dailyChallenge,
      weeklyChallenge: overview.weeklyChallenge,
      categoryMastery: overview.categoryMastery,
      recentXpEvents: refreshedEvents,
      isPremium: overview.isPremium,
      xpMultiplier: overview.xpMultiplier,
    );
  }

  Future<UserGameProfileModel?> _loadPersistedProfile(String userId) async {
    try {
      final appwrite_models.Document document = await _databases.getDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationProfilesCollectionId,
        documentId: userId,
      );
      return UserGameProfileModel.fromDocument(document);
    } on AppwriteException catch (exception) {
      if (exception.code == 404) {
        return null;
      }
      rethrow;
    }
  }

  List<DailyLogModel> _mergeTodayLog(
    List<DailyLogModel> logs,
    DailyLog todayLog,
  ) {
    final List<DailyLogModel> merged = List<DailyLogModel>.of(logs)
      ..removeWhere((DailyLogModel log) => log.dateKey == todayLog.dateKey);
    merged.add(DailyLogModel.fromEntity(todayLog));
    merged.sort(
      (DailyLogModel a, DailyLogModel b) => a.dateKey.compareTo(b.dateKey),
    );
    return merged;
  }

  Future<List<GamificationXpEventModel>> _fetchXpEvents(String userId) async {
    final appwrite_models.DocumentList documents = await _databases
        .listDocuments(
          databaseId: _envConfig.appwriteDatabaseId,
          collectionId: _envConfig.gamificationEventsCollectionId,
          queries: <String>[Query.orderDesc('\$createdAt'), Query.limit(50)],
        );

    return documents.documents
        .map(GamificationXpEventModel.fromDocument)
        .toList(growable: false);
  }

  Future<List<DailyLogModel>> _loadLogsWithItems(
    String userId, {
    required int dayWindow,
  }) async {
    final DateTime cutoff = DateTime.now().toUtc().subtract(
      Duration(days: dayWindow),
    );
    final String cutoffKey = _dateKey(cutoff);

    final appwrite_models.DocumentList documents = await _databases
        .listDocuments(
          databaseId: _envConfig.appwriteDatabaseId,
          collectionId: _envConfig.dailyLogsCollectionId,
          queries: <String>[
            Query.greaterThanEqual('log_date', cutoffKey),
            Query.orderAsc('log_date'),
            // Range is inclusive of both ends → dayWindow + 1 distinct dates;
            // limit(dayWindow) would drop the newest (today) at saturation.
            Query.limit(dayWindow + 1),
          ],
        );

    final List<String> logIds = documents.documents
        .map((appwrite_models.Document document) => document.$id)
        .toList(growable: false);
    final Map<String, List<DailyLogItemModel>> itemsByLogId =
        await _loadItemsByLogIds(userId, logIds);

    return documents.documents
        .map((appwrite_models.Document document) {
          final String logId = document.$id;
          return DailyLogModel.fromDocument(
            document: document,
            items: itemsByLogId[logId] ?? const <DailyLogItemModel>[],
          );
        })
        .toList(growable: false);
  }

  Future<Map<String, List<DailyLogItemModel>>> _loadItemsByLogIds(
    String userId,
    List<String> logIds,
  ) async {
    if (logIds.isEmpty) {
      return const <String, List<DailyLogItemModel>>{};
    }

    final appwrite_models.DocumentList itemDocuments = await _databases
        .listDocuments(
          databaseId: _envConfig.appwriteDatabaseId,
          collectionId: _envConfig.dailyLogItemsCollectionId,
          queries: <String>[Query.limit(5000)],
        );

    final Map<String, List<DailyLogItemModel>> itemsByLogId =
        <String, List<DailyLogItemModel>>{};
    for (final appwrite_models.Document document in itemDocuments.documents) {
      final String? logDocumentIdFromData = document.data['log_document_id']
          ?.toString();
      String? matchedLogId;
      if (logDocumentIdFromData != null &&
          logDocumentIdFromData.isNotEmpty &&
          logIds.contains(logDocumentIdFromData)) {
        matchedLogId = logDocumentIdFromData;
      } else {
        for (final String logId in logIds) {
          if (DailyLogDocumentIds.isLegacyItemForLog(document.$id, logId)) {
            matchedLogId = logId;
            break;
          }
        }
      }
      if (matchedLogId == null) {
        continue;
      }
      itemsByLogId
          .putIfAbsent(matchedLogId, () => <DailyLogItemModel>[])
          .add(DailyLogItemModel.fromDocumentWithoutCategory(document));
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
        data: <String, dynamic>{...data, 'created_at': now},
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
    required String eventType,
    required bool isPremium,
  }) async {
    if (!challenge.isCompleted) {
      return;
    }

    if (challenge.isPremiumOnly && !isPremium) {
      return;
    }

    final bool exists = persistedEvents.any(
      (GamificationXpEvent event) =>
          event.eventType == eventType && event.logDate == challenge.dateKey,
    );
    if (exists) {
      return;
    }

    await _createEventIfMissing(
      userId: userId,
      eventType: eventType,
      xpDelta: challenge.xpReward,
      logDate: challenge.dateKey,
      createdAt: DateTime.now().toUtc(),
      metadata: <String, Object?>{
        'challenge_id': challenge.id,
        'challenge_title': challenge.title,
        'challenge_period': challenge.period.name,
        'level': profile.currentLevel.level,
        'xp': profile.totalXp,
      },
    );
  }

  Future<void> _upsertStreakFreezeEvents({
    required String userId,
    required UserGameProfile? previousProfile,
    required UserGameProfile nextProfile,
  }) async {
    final Set<String> previousUsed =
        (previousProfile?.streakFreezeUsedDates ?? const <String>[]).toSet();
    for (final String date in nextProfile.streakFreezeUsedDates) {
      if (previousUsed.contains(date)) {
        continue;
      }
      await _createEventIfMissing(
        userId: userId,
        eventType: 'streak_freeze_used',
        xpDelta: 0,
        logDate: date,
        createdAt: DateTime.now().toUtc(),
        metadata: <String, Object?>{
          'missed_date': date,
          'freezes_remaining': nextProfile.streakFreezesRemaining,
        },
      );
    }
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

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
