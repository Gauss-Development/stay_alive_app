import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads [assets/env/app.env.example] (committed defaults).
///
/// **Local secrets:** copy the file to `assets/env/app.env`, add it under
/// `flutter: assets:` in [pubspec.yaml], then load that file here instead of
/// (or in addition to) the example — or use `--dart-define=KEY=value` /
/// `--dart-define-from-file`, which take precedence in [EnvConfig.fromEnv].
Future<void> loadEnvFiles() async {
  await dotenv.load(fileName: 'assets/env/app.env.example');
}
