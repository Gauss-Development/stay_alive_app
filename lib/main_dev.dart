import 'package:stay_alive/bootstrap.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Development flavor. Run with:
/// `flutter run --flavor dev -t lib/main_dev.dart`
void main() => bootstrap(AppFlavor.development);
