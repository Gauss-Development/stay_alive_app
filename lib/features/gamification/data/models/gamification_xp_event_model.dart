import 'dart:convert';

import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';

class GamificationXpEventModel extends GamificationXpEvent {
  const GamificationXpEventModel({
    required super.eventId,
    required super.eventType,
    required super.label,
    required super.xpDelta,
    required super.logDate,
    required super.createdAt,
  });

  factory GamificationXpEventModel.fromRow(Map<String, dynamic> data) {
    return GamificationXpEventModel(
      eventId: data['event_id']?.toString() ?? data['id']?.toString() ?? '',
      eventType: data['event_type']?.toString() ?? '',
      label: _labelForEventType(data['event_type']?.toString() ?? ''),
      xpDelta: (data['xp_delta'] as num?)?.toInt() ?? 0,
      logDate: _logDateFromRow(data),
      createdAt:
          DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.tryParse(data['inserted_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  static String _logDateFromRow(Map<String, dynamic> data) {
    final String? storedDate = data['log_date']?.toString();
    if (storedDate != null && storedDate.isNotEmpty) {
      return storedDate;
    }
    final Object? metadata = data['metadata_json'];
    if (metadata is String && metadata.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(metadata);
        if (decoded is Map<String, dynamic>) {
          final String? metadataDate = decoded['log_date']?.toString();
          if (metadataDate != null && metadataDate.isNotEmpty) {
            return metadataDate;
          }
        }
      } on FormatException {
        return '';
      }
    }
    return '';
  }

  static String _labelForEventType(String eventType) {
    return switch (eventType) {
      'challenge_completed' => 'Daily challenge completed',
      'weekly_challenge_completed' => 'Weekly challenge completed',
      'streak_freeze_used' => 'Streak freeze used',
      'level_up' => 'Level up',
      'firstStep' => 'Badge: First Step',
      'perfectDay' => 'Badge: Perfect Day',
      'weekStreak' => 'Badge: Week Warrior',
      'ironWill' => 'Badge: Iron Will',
      'earlyBird' => 'Badge: Early Bird',
      'centurion' => 'Badge: Centurion',
      'winterWellness' => 'Badge: Winter Wellness',
      'secretKeeper' => 'Badge: Secret Keeper',
      'patron' => 'Badge: Patron',
      'first_log' => 'Badge: First Log',
      'perfect_day' => 'Badge: Perfect Day',
      'seven_day_streak' => 'Badge: Week Warrior',
      _ => eventType,
    };
  }
}
