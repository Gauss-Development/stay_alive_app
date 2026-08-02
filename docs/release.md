# Release setup

Stay Alive ships as a paid app with monthly + yearly subscriptions, distributed through the App Store and Google Play. This doc is the one-stop reference for the human work required before a release build is shippable.

## 1. Identifiers

- iOS bundle (production): `com.gaussdev.stayalive`
- iOS bundle (dev): `com.gaussdev.stayalive.dev`
- iOS widget extension: `com.gaussdev.stayalive.DailyGoalWidget` (+ `.dev` variant)
- iOS App Group: `group.com.gaussdev.stayalive`
- Android applicationId (production): `com.gaussdev.stayalive`
- Android applicationId (dev): `com.gaussdev.stayalive.dev`

All references live in:

- `ios/Flutter/{Debug,Release,Profile}-{dev,prod}.xcconfig`
- `ios/Runner.xcodeproj/project.pbxproj` (widget + test targets)
- `ios/Runner/Runner.entitlements`, `ios/DailyGoalWidget/DailyGoalWidgetExtension.entitlements`
- `ios/DailyGoalWidget/DailyGoalWidget.swift` (`appGroupId`)
- `android/app/build.gradle.kts` (`namespace`, `applicationId`)
- `android/app/src/main/kotlin/com/gaussdev/stayalive/`

## 2. App Store Connect

1. Create a new app entry with bundle id `com.gaussdev.stayalive`.
2. Under **In-App Purchases**, create two **Auto-Renewable Subscriptions** in a single subscription group named `premium`:
   - **Monthly** — product id `com.gaussdev.stayalive.premium.monthly`, duration 1 month
   - **Annual** — product id `com.gaussdev.stayalive.premium.annual`, duration 1 year
3. Add localized display name, description, and review screenshot per subscription.
4. Under **App Privacy**, declare:
   - Email Address — collected, linked to user, not used for tracking, purpose: App Functionality
   - Purchase History — collected, linked to user, not used for tracking, purpose: App Functionality
   - Product Interaction — collected, linked to user, not used for tracking, purpose: Analytics
   These match `ios/Runner/PrivacyInfo.xcprivacy`.
5. Fill **Privacy Policy URL** and **Terms of Use URL**. Draft documents live in `docs/legal/`; host them over HTTPS, then put the live URLs into `lib/core/constants/legal_urls.dart` (currently placeholder `stay-alive.app`, which 404s) and into both store listings (ticket GAU-315).
6. **Export compliance:** `ITSAppUsesNonExemptEncryption` is set to `false` in `Info.plist`, so no export-compliance prompt should appear.

## 3. Google Play Console

1. Create a new app entry with package name `com.gaussdev.stayalive`.
2. Under **Monetize → Subscriptions**, create:
   - **Monthly** — product id `com.gaussdev.stayalive.premium.monthly`, billing period P1M
   - **Annual** — product id `com.gaussdev.stayalive.premium.annual`, billing period P1Y
3. Fill the **Data Safety** form to match `App Privacy` above.
4. Enroll in **Play App Signing** (generate the upload keystore separately — see section 6).
5. Set `targetSdk ≥ 34` (current Play requirement). Flutter's default already satisfies this; verify with `flutter build appbundle --release --flavor prod` output.

## 4. RevenueCat dashboard

Create a new RevenueCat project named **Stay Alive**.

1. **Apps** → Add iOS app:
   - Bundle id: `com.gaussdev.stayalive`
   - Connect App Store Connect (paste your in-app-purchase shared secret; if subscriptions only, generate an App Store Connect API key with the App Manager role).
2. **Apps** → Add Android app:
   - Package: `com.gaussdev.stayalive`
   - Connect Google Play: upload the Service Account JSON for the Play Developer API.
3. **Products** → Import:
   - `com.gaussdev.stayalive.premium.monthly` (both platforms)
   - `com.gaussdev.stayalive.premium.annual` (both platforms)
4. **Entitlements** → Create `premium`. Attach both products to it.
5. **Offerings** → Create `default`. Add two packages:
   - `$rc_monthly` → monthly product
   - `$rc_annual` → annual product
   Mark `default` as the current offering.
6. **Project → APIs** → Copy the two SDK keys (iOS `appl_…`, Android `goog_…`). These go into `scripts/release.env`.

The app code's plan resolver (`SubscriptionPlan.fromRevenueCatIdentifier`) matches on `$rc_monthly` / `$rc_annual` and the words `monthly` / `annual` / `year` in identifiers, so the canonical package IDs above are recommended.

## 5. Sentry

1. Create a Sentry project (Flutter platform).
2. Copy the DSN.
3. Add to `scripts/release.env` as `SENTRY_DSN=...`.
4. App-side wiring already done in `lib/bootstrap.dart`. When DSN is empty, Sentry is skipped (used for local dev).

## 6. Appwrite account-deletion function (store requirement)

Both stores require full account deletion. The client deletes the user's
documents and sessions, but the Appwrite auth record itself must be removed
server-side by the `functions/delete_user` function (ticket GAU-316).

1. Deploy it (needs an Appwrite API key with `users.write`):

   ```sh
   appwrite functions create \
     --function-id delete_user --name "delete_user" \
     --runtime node-22 --execute '["users"]'

   appwrite functions create-deployment \
     --function-id delete_user --entrypoint "src/main.js" \
     --code functions/delete_user --activate true
   ```

2. Enable a **dynamic API key** with scope `users.write` on the function.
3. Set the id in `scripts/release.env`: `APPWRITE_DELETE_USER_FUNCTION_ID=delete_user`.

When this id is empty, the app clears documents/sessions and signs the user out
but skips the auth-record deletion (dev fallback — **not** store-compliant).
Details: `functions/delete_user/README.md`.

## 7. Android signing

Production builds need an upload keystore (debug keys would be rejected by Play Console). One-time setup:

```sh
keytool -genkey -v -keystore ~/.android/stay-alive-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `android/key.properties.example` to `android/key.properties` and fill in the keystore path + passwords. The file is gitignored.

`android/app/build.gradle.kts` already auto-detects the keystore; if `key.properties` is missing it falls back to debug signing (so local `flutter run --release` still works).

## 8. Build and ship

Copy the secrets template:

```sh
cp scripts/release.env.example scripts/release.env
# edit scripts/release.env with real values
```

Build artifacts:

```sh
./scripts/build-prod.sh appbundle  # AAB for Play Store upload
./scripts/build-prod.sh ipa        # iOS archive (then open in Xcode → Distribute App)
```

For iOS, sign with your Apple Developer team in Xcode (manual or automatic signing) and validate via Product → Archive → Distribute App → Validate before App Store Connect upload.

## 9. Pre-flight checklist

Before every release:

- [ ] `flutter analyze` returns no issues
- [ ] `flutter test` passes
- [ ] `scripts/release.env` has real RevenueCat keys + `APPWRITE_DELETE_USER_FUNCTION_ID=delete_user`
- [ ] `lib/core/constants/legal_urls.dart` points at the live hosted legal URLs
- [ ] `./scripts/build-prod.sh apk` succeeds and the APK installs on a real Android device
- [ ] Manual smoke: sign up → log a day → open paywall → see Monthly + Annual → sandbox purchase → entitlement activates
- [ ] Manual smoke: settings → Delete account → confirm → all data gone, fresh signup with same email works
- [ ] Bump `version: x.y.z+n` in `pubspec.yaml`
- [ ] Tag the release commit in git
