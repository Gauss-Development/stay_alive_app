import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Loads env layers in order (later wins):
/// 1. [assets/env/app.env.example] — committed defaults
/// 2. `assets/env/app.dev.env` or `assets/env/app.prod.env` — flavor defaults
/// 3. `assets/env/app.env` — optional local overrides (add the file to
///    `pubspec.yaml` assets when you use it; it is gitignored by convention)
///
/// CI / release: prefer `--dart-define=KEY=value` or `--dart-define-from-file`,
/// which override values in [EnvConfig.fromEnv].
Future<void> loadEnvForFlavor(AppFlavor flavor) async {
  await dotenv.load(fileName: 'assets/env/app.env.example');
  final String flavorAsset = switch (flavor) {
    AppFlavor.development => 'assets/env/app.dev.env',
    AppFlavor.production => 'assets/env/app.prod.env',
  };
  await dotenv.load(fileName: flavorAsset, mergeWith: dotenv.env);
  try {
    await dotenv.load(fileName: 'assets/env/app.env', mergeWith: dotenv.env);
  } on Exception {
    // Optional `app.env` is often omitted from the asset bundle.
  }
}
