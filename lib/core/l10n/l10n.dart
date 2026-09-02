import 'package:flutter/widgets.dart';
import 'package:stay_alive/l10n/app_localizations.dart';

export 'package:stay_alive/l10n/app_localizations.dart';

/// Shorthand for the generated strings: `context.l10n.navHome`.
///
/// `nullable-getter: false` in `l10n.yaml` means this never returns null —
/// every screen sits under the `MaterialApp` that installs the delegates.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Locales the app ships translations for. Russian is first on purpose: it is
/// the source language, so an unsupported device locale falls back to it.
const List<Locale> supportedLocales = <Locale>[
  Locale('ru'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),
];
