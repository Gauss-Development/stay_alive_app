import 'package:appwrite/appwrite.dart';
import 'package:stay_alive/core/env/env_config.dart';

class AppwriteClientProvider {
  AppwriteClientProvider(this._envConfig);

  final EnvConfig _envConfig;

  Client build() {
    return Client()
      ..setEndpoint(_envConfig.appwriteEndpoint)
      ..setProject(_envConfig.appwriteProjectId)
      ..setSelfSigned(status: _envConfig.allowSelfSigned);
  }
}
