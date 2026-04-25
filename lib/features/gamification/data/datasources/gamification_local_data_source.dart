import 'package:shared_preferences/shared_preferences.dart';

abstract class GamificationLocalDataSource {
  Future<int> getTotalXp();
  Future<void> setTotalXp(int xp);

  Future<int> getTotalCategoriesCompleted();
  Future<void> setTotalCategoriesCompleted(int count);

  Future<List<String>> getCompletedDates();
  Future<void> setCompletedDates(List<String> dates);

  Future<List<String>> getEarlyLogDates();
  Future<void> setEarlyLogDates(List<String> dates);

  Future<List<String>> getBadgeIds();
  Future<List<String>> getBadgeTimestamps();
  Future<void> setBadges(List<String> ids, List<String> timestamps);
}

abstract final class _Keys {
  static const String totalXp = 'gami_total_xp';
  static const String totalCats = 'gami_total_cats';
  static const String completedDates = 'gami_completed_dates';
  static const String earlyLogDates = 'gami_early_log_dates';
  static const String badgeIds = 'gami_badge_ids';
  static const String badgeTimestamps = 'gami_badge_timestamps';
}

class SharedPrefsGamificationDataSource implements GamificationLocalDataSource {
  const SharedPrefsGamificationDataSource(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<int> getTotalXp() async =>
      _prefs.getInt(_Keys.totalXp) ?? 0;

  @override
  Future<void> setTotalXp(int xp) async =>
      _prefs.setInt(_Keys.totalXp, xp);

  @override
  Future<int> getTotalCategoriesCompleted() async =>
      _prefs.getInt(_Keys.totalCats) ?? 0;

  @override
  Future<void> setTotalCategoriesCompleted(int count) async =>
      _prefs.setInt(_Keys.totalCats, count);

  @override
  Future<List<String>> getCompletedDates() async =>
      _prefs.getStringList(_Keys.completedDates) ?? <String>[];

  @override
  Future<void> setCompletedDates(List<String> dates) async =>
      _prefs.setStringList(_Keys.completedDates, dates);

  @override
  Future<List<String>> getEarlyLogDates() async =>
      _prefs.getStringList(_Keys.earlyLogDates) ?? <String>[];

  @override
  Future<void> setEarlyLogDates(List<String> dates) async =>
      _prefs.setStringList(_Keys.earlyLogDates, dates);

  @override
  Future<List<String>> getBadgeIds() async =>
      _prefs.getStringList(_Keys.badgeIds) ?? <String>[];

  @override
  Future<List<String>> getBadgeTimestamps() async =>
      _prefs.getStringList(_Keys.badgeTimestamps) ?? <String>[];

  @override
  Future<void> setBadges(List<String> ids, List<String> timestamps) async {
    await _prefs.setStringList(_Keys.badgeIds, ids);
    await _prefs.setStringList(_Keys.badgeTimestamps, timestamps);
  }
}
