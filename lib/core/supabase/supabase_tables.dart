/// Postgres table names (public schema). Fixed by the schema migration in
/// `supabase/migrations/`, so they are code constants, not configuration.
abstract final class SupabaseTables {
  static const String profiles = 'profiles';
  static const String categoryDefinitions = 'category_definitions';
  static const String dailyLogs = 'daily_logs';
  static const String dailyLogItems = 'daily_log_items';
  static const String gamificationProfiles = 'gamification_profiles';
  static const String gamificationEvents = 'gamification_events';
  static const String analyticsEvents = 'analytics_events';
}

/// Edge function names (deployed from `supabase/functions/`).
abstract final class SupabaseFunctions {
  static const String deleteUser = 'delete_user';
  static const String aiCoach = 'ai_coach';
}
