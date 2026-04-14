# Flutter Architecture Overview

This codebase follows feature-first Clean Architecture with strict boundaries.

## Project Structure

```text
lib/
├── app.dart
├── main.dart
├── router.dart
├── core/
│   ├── constants/
│   ├── di/
│   ├── env/
│   ├── error/
│   ├── logger/
│   ├── network/
│   ├── result/
│   ├── services/
│   └── usecase/
├── shared/
│   ├── theme/
│   └── widgets/
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories_impl/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── cubit/
    │       ├── pages/
    │       └── widgets/
    ├── daily_tracker/
    ├── user/
    ├── history/
    ├── analytics/
    ├── categories/
    ├── subscription/
    └── education/
```

## Layer Rules

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** does not depend on Flutter/Appwrite

## Environment Configuration

The app reads Appwrite configuration from compile-time `--dart-define` values.

Required keys:

- `APPWRITE_ENDPOINT`
- `APPWRITE_PROJECT_ID`
- `APPWRITE_DATABASE_ID`
- `APPWRITE_USERS_COLLECTION_ID`
- `APPWRITE_CATEGORY_DEFINITIONS_COLLECTION_ID`
- `APPWRITE_DAILY_LOGS_COLLECTION_ID`
- `APPWRITE_DAILY_LOG_ITEMS_COLLECTION_ID`
- `APPWRITE_SUBSCRIPTIONS_COLLECTION_ID`
- `APPWRITE_ANALYTICS_EVENTS_COLLECTION_ID`
- `APPWRITE_EDUCATIONAL_CONTENT_COLLECTION_ID`
- `APPWRITE_AVATARS_BUCKET_ID`
- `APPWRITE_USER_UPLOADS_BUCKET_ID`
- `APPWRITE_CONTENT_ASSETS_BUCKET_ID`
- `APPWRITE_SELF_SIGNED`

Example:

```bash
flutter run \
  --dart-define=APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
  --dart-define=APPWRITE_PROJECT_ID=<PROJECT_ID> \
  --dart-define=APPWRITE_DATABASE_ID=daily_dozen_db
```

## Deployment Notes

- Use separate Appwrite projects for `dev` and `prod`.
- Keep OAuth callback scheme aligned with the active project ID:
  - Android: `appwrite-callback-<PROJECT_ID>` in `AndroidManifest.xml`
  - iOS: `appwrite-callback-<PROJECT_ID>` in `Info.plist`
- Configure CI/CD to pass environment-specific `--dart-define` values.
