import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/gamification/data/models/gamification_progress_model.dart';

abstract class GamificationRemoteDataSource {
  Future<GamificationProgressModel> fetchProgress();
}

class AppwriteGamificationRemoteDataSource
    implements GamificationRemoteDataSource {
  AppwriteGamificationRemoteDataSource({
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
  Future<GamificationProgressModel> fetchProgress() async {
    final appwrite_models.User user = await _account.get();
    final List<DailyLogModel> logs = await _loadLogs(user.$id);
    final GamificationProgressModel progress = _calculateProgress(
      userId: user.$id,
      logs: logs,
    );
    await _upsertProfile(progress);
    await _upsertBadgeEvents(progress);
    return progress;
  }

  Future<List<DailyLogModel>> _loadLogs(String userId) async {
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
    return documents.documents
        .map(
          (appwrite_models.Document document) => DailyLogModel.fromDocument(
            document: document,
            items: const <DailyLogItemModel>[],
          ),
        )
        .toList(growable: false);
  }

  GamificationProgressModel _calculateProgress({
    required String userId,
    required List<DailyLogModel> logs,
  }) {
    int xp = 0;
    int completedDays = 0;
    int currentStreak = 0;
    int bestStreak = 0;
    String? lastCompletedDate;
    DateTime? previousCompletedDate;
    final Set<String> badges = <String>{};

    for (final DailyLogModel log in logs) {
      if (log.totalCompleted > 0) {
        badges.add('first_log');
      }
      xp += log.totalCompleted * 5;

      if (!log.isFullyCompleted) {
        continue;
      }

      badges.add('perfect_day');
      completedDays += 1;
      xp += 25;

      if (previousCompletedDate == null) {
        currentStreak = 1;
      } else {
        final int dayGap = DateTime.utc(
          log.logDate.year,
          log.logDate.month,
          log.logDate.day,
        )
            .difference(
              DateTime.utc(
                previousCompletedDate.year,
                previousCompletedDate.month,
                previousCompletedDate.day,
              ),
            )
            .inDays;
        currentStreak = dayGap == 1 ? currentStreak + 1 : 1;
      }

      if (currentStreak > 1) {
        xp += 10;
      }
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
      previousCompletedDate = log.logDate;
      lastCompletedDate = log.dateKey;
    }

    if (bestStreak >= 3) {
      badges.add('three_day_streak');
    }
    if (bestStreak >= 7) {
      badges.add('seven_day_streak');
    }

    final int level = (xp / 100).floor() + 1;
    final int nextLevelXp = level * 100;
    final int currentLevelBaseXp = (level - 1) * 100;

    return GamificationProgressModel(
      userId: userId,
      xp: xp,
      level: level,
      nextLevelXp: nextLevelXp,
      currentLevelXp: currentLevelBaseXp,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      completedDays: completedDays,
      lastCompletedDate: lastCompletedDate,
      badges: badges.toList(growable: false)..sort(),
    );
  }

  Future<void> _upsertProfile(GamificationProgressModel progress) async {
    final String now = DateTime.now().toUtc().toIso8601String();
    final Map<String, dynamic> data = progress.toDocumentData(now: now);
    try {
      await _databases.updateDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationProfilesCollectionId,
        documentId: progress.userId,
        data: data,
      );
    } on AppwriteException catch (exception) {
      if (exception.code != 404) {
        rethrow;
      }
      await _databases.createDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationProfilesCollectionId,
        documentId: progress.userId,
        data: <String, dynamic>{
          ...data,
          'created_at': now,
        },
        permissions: <String>[
          Permission.read(Role.user(progress.userId)),
          Permission.update(Role.user(progress.userId)),
          Permission.delete(Role.user(progress.userId)),
        ],
      );
    }
  }

  Future<void> _upsertBadgeEvents(GamificationProgressModel progress) async {
    for (final String badge in progress.badges) {
      final appwrite_models.DocumentList existing = await _databases
          .listDocuments(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.gamificationEventsCollectionId,
        queries: <String>[
          Query.equal('user_id', progress.userId),
          Query.equal('event_type', badge),
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
            'user_id': progress.userId,
            'event_type': badge,
            'xp_delta': 0,
            'log_date': progress.lastCompletedDate ?? '',
            'metadata_json': jsonEncode(<String, Object?>{
              'level': progress.level,
              'xp': progress.xp,
            }),
            'created_at': DateTime.now().toUtc().toIso8601String(),
          },
          permissions: <String>[Permission.read(Role.user(progress.userId))],
        );
      } on AppwriteException catch (exception) {
        if (exception.code != 409) {
          rethrow;
        }
      }
    }
  }
}
