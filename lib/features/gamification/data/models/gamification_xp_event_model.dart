import 'package:appwrite/models.dart' as appwrite_models;
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

  factory GamificationXpEventModel.fromDocument(
    appwrite_models.Document document,
  ) {
    final Map<String, dynamic> data = document.data;
    return GamificationXpEventModel(
      eventId: data['event_id']?.toString() ?? document.$id,
      eventType: data['event_type']?.toString() ?? '',
      label: _labelForEventType(data['event_type']?.toString() ?? ''),
      xpDelta: (data['xp_delta'] as num?)?.toInt() ?? 0,
      logDate: data['log_date']?.toString() ?? '',
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.tryParse(document.$createdAt) ??
          DateTime.now().toUtc(),
    );
  }

  static String _labelForEventType(String eventType) {
    return switch (eventType) {
      'challenge_completed' => 'Daily challenge completed',
      'level_up' => 'Level up',
      'firstStep' => 'Badge: First Step',
      'perfectDay' => 'Badge: Perfect Day',
      'weekStreak' => 'Badge: Week Warrior',
      'ironWill' => 'Badge: Iron Will',
      'earlyBird' => 'Badge: Early Bird',
      'centurion' => 'Badge: Centurion',
      'first_log' => 'Badge: First Log',
      'perfect_day' => 'Badge: Perfect Day',
      'seven_day_streak' => 'Badge: Week Warrior',
      _ => eventType,
    };
  }
}
