import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-chosen appearance and language.
///
/// Both fields are deliberately nullable-by-"system": a null [locale] means
/// "follow the device", which is the default and must stay distinguishable
/// from an explicit choice that happens to match the device.
class AppSettings extends Equatable {
  const AppSettings({this.locale, this.themeMode = ThemeMode.system});

  /// `null` = follow the device language.
  final Locale? locale;
  final ThemeMode themeMode;

  AppSettings copyWith({
    Locale? locale,
    bool clearLocale = false,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      locale: clearLocale ? null : (locale ?? this.locale),
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => <Object?>[locale, themeMode];
}

/// Persists [AppSettings] locally.
///
/// Local storage, not the `profiles` row: the theme and language must be known
/// before the first frame, and a network round-trip would flash the wrong
/// language on every cold start.
class SettingsStore {
  const SettingsStore(this._prefs);

  static const String _localeKey = 'settings.locale';
  static const String _themeKey = 'settings.themeMode';

  final SharedPreferences _prefs;

  AppSettings read() {
    final String? languageCode = _prefs.getString(_localeKey);
    final String? themeName = _prefs.getString(_themeKey);
    return AppSettings(
      locale: languageCode == null ? null : Locale(languageCode),
      themeMode: ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      ),
    );
  }

  Future<void> writeLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeKey);
      return;
    }
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);
}
