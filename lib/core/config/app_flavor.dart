/// Build-time environment (Flutter flavor + entrypoint).
///
/// Registered in [GetIt] during bootstrap so services and UI can branch safely.
enum AppFlavor {
  /// Local and QA builds; may use sandbox keys and verbose diagnostics.
  development,

  /// Store / CI release builds; minimize debug surface and use production backends.
  production,
}

extension AppFlavorX on AppFlavor {
  bool get isDevelopment => this == AppFlavor.development;

  bool get isProduction => this == AppFlavor.production;
}
