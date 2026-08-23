import 'dart:convert';

import 'package:stay_alive/core/supabase/supabase_tables.dart';
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
import 'package:stay_alive/features/gamification/domain/entities/personalized_challenge_draft.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_engine.dart';
import 'package:stay_alive/features/gamification/domain/services/gamification_overview_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class GamificationRemoteDataSource {
  Future<GamificationOverviewModel> reconcileOverview({
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  });

  Future<GamificationOverviewModel> reconcileTodayOverview({
    required DailyLog todayLog,
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  });
}

class SupabaseGamificationRemoteDataSource
    implements GamificationRemoteDataSource {
  SupabaseGamificationRemoteDataSource({
    required supabase.SupabaseClient client,
    required supabase.GoTrueClient auth,
    GamificationEngine? engine,
    GamificationOverviewBuilder? overviewBuilder,
  })  : _client = client,
        _auth = auth,
        _overviewBuilder =
            overviewBuilder ?? GamificationOverviewBuilder(engine: engine);

  final supabase.SupabaseClient _client;
  final supabase.GoTrueClient _auth;
  final GamificationOverviewBuilder _overviewBuilder;

  static const int _fullReconcileDayWindow = 365;
  static const int _todayReconcileDayWindow = 45;

  @override
  Future<GamificationOverviewModel> reconcileOverview({
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  }) async {
    final String userId = _requireUserId();
    // Independent reads run concurrently — reconcile is on the home-screen path.
    final List<Object?> reads = await Future.wait(<Future<Object?>>[
      _loadPersistedProfile(userId),
      _loadLogsWithItems(userId, dayWindow: _fullReconcileDayWindow),
      _fetchXpEvents(userId),
    ]);

    return _buildAndPersist(
      userId: userId,
      logs: reads[1]! as List<DailyLogModel>,
      persistedEvents: reads[2]! as List<GamificationXpEventModel>,
      isPremium: isPremium,
      persistedProfile: reads[0] as UserGameProfileModel?,
      personalizedDailyDraft: personalizedDailyDraft,
    );
  }

  @override
  Future<GamificationOverviewModel> reconcileTodayOverview({
    required DailyLog todayLog,
    required bool isPremium,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  }) async {
    final String userId = _requireUserId();
    // Independent reads run concurrently — reconcile is on the home-screen path.
    final List<Object?> reads = await Future.wait(<Future<Object?>>[
      _loadPersistedProfile(userId),
      _loadLogsWithItems(userId, dayWindow: _todayReconcileDayWindow),
      _fetchXpEvents(userId),
    ]);
    final List<DailyLogModel> mergedLogs = _mergeTodayLog(
      reads[1]! as List<DailyLogModel>,
      todayLog,
    );

    return _buildAndPersist(
      userId: userId,
      logs: mergedLogs,
      persistedEvents: reads[2]! as List<GamificationXpEventModel>,
      isPremium: isPremium,
      persistedProfile: reads[0] as UserGameProfileModel?,
      personalizedDailyDraft: personalizedDailyDraft,
    );
  }

  Future<GamificationOverviewModel> _buildAndPersist({
    required String userId,
    required List<DailyLogModel> logs,
    required List<GamificationXpEventModel> persistedEvents,
    required bool isPremium,
    required UserGameProfileModel? persistedProfile,
    PersonalizedChallengeDraft? personalizedDailyDraft,
  }) async {
    final GamificationOverview overview = _overviewBuilder.build(
      userId: userId,
      logs: logs,
      persistedEvents: persistedEvents,
      isPremium: isPremium,
      streakFreezesRemaining: persistedProfile?.streakFreezesRemaining ?? 0,
      streakFreezeUsedDates:
          persistedProfile?.streakFreezeUsedDates ?? const <String>[],
      personalizedDailyDraft: personalizedDailyDraft,
    );

    final UserGameProfileModel profileModel = UserGameProfileModel.fromProfile(
      overview.profile,
    );
    // These writes target distinct rows and don't read each other's results
    // (dedup uses the pre-write persistedEvents snapshot), so they run
    // concurrently; all complete before the event re-fetch below.
    await Future.wait(<Future<void>>[
      _upsertProfile(profileModel),
      _upsertBadgeEvents(profileModel),
      _upsertChallengeEvent(
        userId: userId,
        challenge: overview.dailyChallenge,
        profile: overview.profile,
        persistedEvents: persistedEvents,
        eventType: 'challenge_completed',
        isPremium: isPremium,
      ),
      _upsertChallengeEvent(
        userId: userId,
        challenge: overview.weeklyChallenge,
        profile: overview.profile,
        persistedEvents: persistedEvents,
        eventType: 'weekly_challenge_completed',
        isPremium: isPremium,
      ),
      _upsertStreakFreezeEvents(
        userId: userId,
        previousProfile: persistedProfile,
        nextProfile: overview.profile,
      ),
    ]);

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
    final Map<String, dynamic>? row = await _client
        .from(SupabaseTables.gamificationProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return UserGameProfileModel.fromRow(row);
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
    // Ordered by the server insert time (`inserted_at`), not the client-set
    // `created_at`, which is backdated for badge events — parity with the old
    // `$createdAt` ordering.
    final List<Map<String, dynamic>> rows = await _client
        .from(SupabaseTables.gamificationEvents)
        .select()
        .eq('user_id', userId)
        .order('inserted_at', ascending: false)
        .limit(50);

    return rows
        .map(GamificationXpEventModel.fromRow)
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

    // One embedded select replaces the old two-phase load (logs, then items
    // chunked by log id with cursor pagination).
    final List<Map<String, dynamic>> rows = await _client
        .from(SupabaseTables.dailyLogs)
        .select('*, ${SupabaseTables.dailyLogItems}(*)')
        .eq('user_id', userId)
        .gte('log_date', cutoffKey)
        .order('log_date', ascending: true)
        // Range is inclusive of both ends → dayWindow + 1 distinct dates;
        // limit(dayWindow) would drop the newest (today) at saturation.
        .limit(dayWindow + 1);

    return rows
        .map((Map<String, dynamic> row) {
          final List<DailyLogItemModel> items =
              ((row[SupabaseTables.dailyLogItems] as List<dynamic>?) ??
                      const <dynamic>[])
                  .map(
                    (dynamic itemRow) => DailyLogItemModel.fromRow(
                      itemRow as Map<String, dynamic>,
                    ),
                  )
                  .toList(growable: false);
          return DailyLogModel.fromRow(row: row, items: items);
        })
        .toList(growable: false);
  }

  Future<void> _upsertProfile(UserGameProfileModel profile) async {
    final String now = DateTime.now().toUtc().toIso8601String();
    await _client.from(SupabaseTables.gamificationProfiles).upsert(
          profile.toRowData(now: now),
          onConflict: 'user_id',
        );
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
    // Pre-check keeps the old read-then-insert behaviour; the unique
    // (user_id, event_type, log_date) key + DO NOTHING makes races harmless.
    final List<Map<String, dynamic>> existing = await _client
        .from(SupabaseTables.gamificationEvents)
        .select('id')
        .eq('user_id', userId)
        .eq('event_type', eventType)
        .eq('log_date', logDate)
        .limit(1);
    if (existing.isNotEmpty) {
      return;
    }

    await _client.from(SupabaseTables.gamificationEvents).upsert(
      <String, dynamic>{
        'event_type': eventType,
        'xp_delta': xpDelta,
        'log_date': logDate,
        'metadata_json': jsonEncode(metadata),
        'created_at': createdAt.toIso8601String(),
      },
      onConflict: 'user_id,event_type,log_date',
      ignoreDuplicates: true,
    );
  }

  String _requireUserId() {
    final String? userId = _auth.currentUser?.id;
    if (userId == null) {
      throw const supabase.AuthException(
        'No active session.',
        statusCode: '401',
      );
    }
    return userId;
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
