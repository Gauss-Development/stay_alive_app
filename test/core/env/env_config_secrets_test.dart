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

  test('production refuses the committed local Supabase fallbacks', () {
    // A prod build without injected SUPABASE_* must resolve to empty so
    // bootstrap fails loudly instead of silently talking to a dev backend.
    final EnvConfig prod = EnvConfig.fromEnv(AppFlavor.production);

    expect(prod.supabaseUrl, isEmpty);
    expect(prod.supabaseAnonKey, isEmpty);
  });

  test('development falls back to the local supabase start stack', () {
    final EnvConfig dev = EnvConfig.fromEnv(AppFlavor.development);

    expect(dev.supabaseUrl, 'http://127.0.0.1:54321');
    expect(dev.supabaseAnonKey, isNotEmpty);
  });

  test('non-credential defaults are untouched by the production guard', () {
    final EnvConfig prod = EnvConfig.fromEnv(AppFlavor.production);

    expect(prod.revenueCatEntitlementId, 'Stay Alive Pro');
    expect(prod.revenueCatOfferingId, 'default');
    expect(prod.widgetAppGroupId, isNotEmpty);
  });
}
