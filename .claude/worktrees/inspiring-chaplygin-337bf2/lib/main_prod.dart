import 'package:stay_alive/bootstrap.dart';
import 'package:stay_alive/core/config/app_flavor.dart';

/// Production flavor. Run / ship with:
/// `flutter run --flavor prod -t lib/main_prod.dart`
/// `flutter build apk --flavor prod -t lib/main_prod.dart --release`
void main() => bootstrap(AppFlavor.production);
