/// Public URLs for the app's legal documents.
///
/// Both the App Store and Play Store listings require a reachable Privacy
/// Policy URL, and Apple additionally expects Terms/EULA + Privacy links inside
/// the binary (profile + paywall). The source content lives in `docs/legal/`;
/// host it and replace the placeholders below with the live HTTPS URLs.
///
/// ⚠️ Replace before store submission — these placeholders 404.
class LegalUrls {
  const LegalUrls._();

  static const String privacyPolicy = 'https://stay-alive.app/privacy';
  static const String termsOfService = 'https://stay-alive.app/terms';

  /// True once the placeholders have been swapped for a real host.
  static bool get isConfigured =>
      !privacyPolicy.contains('stay-alive.app') &&
      !termsOfService.contains('stay-alive.app');
}
