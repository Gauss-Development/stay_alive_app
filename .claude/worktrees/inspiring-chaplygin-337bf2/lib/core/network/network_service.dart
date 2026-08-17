abstract class NetworkService {
  Future<bool> get isConnected;
}

class DefaultNetworkService implements NetworkService {
  const DefaultNetworkService();

  @override
  Future<bool> get isConnected async => true;
}
