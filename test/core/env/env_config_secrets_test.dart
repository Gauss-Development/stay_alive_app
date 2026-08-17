import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/env/env_config.dart';

void main() {
  test('production refuses the committed sandbox RevenueCat keys', () {
    // No --dart-define and no .env in a plain test run, so both keys resolve to
    // the committed `test_` fallbacks. Production must treat those as absent:
    // a non-empty sandbox key passes the data source's isEmpty guard and would
    // configure RevenueCat against the sandbox in a shipped build.
    final EnvConfig prod = EnvConfig.fromEnv(AppFlavor.production);

    expect(prod.revenueCatAndroidApiKey, isEmpty);
    expect(prod.revenueCatIosApiKey, isEmpty);
  });

  test('development keeps the sandbox keys so local purchases still work', () {
    final EnvConfig dev = EnvConfig.fromEnv(AppFlavor.development);

    expect(dev.revenueCatAndroidApiKey, startsWith('test_'));
    expect(dev.revenueCatIosApiKey, startsWith('test_'));
  });

  test('non-credential defaults are untouched by the production guard', () {
    final EnvConfig prod = EnvConfig.fromEnv(AppFlavor.production);

    expect(prod.revenueCatEntitlementId, 'Stay Alive Pro');
    expect(prod.revenueCatOfferingId, 'default');
    expect(prod.appwriteDatabaseId, isNotEmpty);
  });
}
