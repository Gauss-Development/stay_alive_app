import 'package:stay_alive/bootstrap.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Default entrypoint for backwards compatibility (development).
///
/// Prefer explicit targets:
/// - `lib/main_dev.dart` with `--flavor dev`
/// - `lib/main_prod.dart` with `--flavor prod`
Future<void> main() => bootstrap(AppFlavor.development);
