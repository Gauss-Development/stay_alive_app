import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/settings/app_settings.dart';

/// Holds the user's language and theme choice for the whole app.
///
/// Seeded synchronously from [SettingsStore] during bootstrap so the very
/// first frame already renders in the chosen language — no flash of the
/// device default.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit({required SettingsStore store, required AppSettings initial})
      : _store = store,
        super(initial);

  final SettingsStore _store;

  /// `null` restores "follow the device".
  Future<void> setLocale(Locale? locale) async {
    if (state.locale == locale) {
      return;
    }
    emit(state.copyWith(locale: locale, clearLocale: locale == null));
    await _store.writeLocale(locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) {
      return;
    }
    emit(state.copyWith(themeMode: mode));
    await _store.writeThemeMode(mode);
  }
}
