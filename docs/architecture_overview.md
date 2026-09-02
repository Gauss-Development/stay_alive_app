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
    ├── gamification/
    ├── coach/
    ├── rostok/
    ├── subscription/
    └── education/
```

## Layer Rules

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** does not depend on Flutter or Supabase

## Environment Configuration

The app reads backend configuration from compile-time `--dart-define` values
(with `assets/env/*.env` fallbacks; see `lib/core/env/env_config.dart`).

Keys:

- `SUPABASE_URL` — dev falls back to the local `supabase start` stack;
  **prod fails closed** (bootstrap throws) when not injected
- `SUPABASE_ANON_KEY` — publishable key; same fail-closed rule
- `REVENUECAT_ANDROID_API_KEY`
- `REVENUECAT_IOS_API_KEY`
- `REVENUECAT_ENTITLEMENT_ID`
- `REVENUECAT_OFFERING_ID`
- `DAILY_GOAL_WIDGET_APP_GROUP_ID`
- `SENTRY_DSN` / `SENTRY_ENVIRONMENT`

Table names and edge-function names are code constants
(`lib/core/supabase/supabase_tables.dart`), not configuration.

Example:

```bash
flutter run --flavor dev -t lib/main_dev.dart \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
```

## Deployment Notes

- Use separate Supabase projects for `dev` and `prod`.
- The schema, RLS policies, seed data and both edge functions live in
  `supabase/`; apply with `supabase db push` + `supabase functions deploy`.
  See `docs/supabase_backend_setup.md`.
- OAuth returns via the `stayalive://login-callback` deep link, registered in
  `AndroidManifest.xml` and `ios/Runner/Info.plist`, and listed in the
  Supabase auth redirect URLs.
- Configure CI/CD to pass environment-specific `--dart-define` values.
- The Android and iOS daily goal widgets read shared values written by
  `DailyGoalWidgetService`. iOS requires the App Group in
  `DAILY_GOAL_WIDGET_APP_GROUP_ID` to be enabled for both Runner and the
  WidgetKit extension in the Apple Developer portal.
- RevenueCat powers premium subscriptions. Configure weekly (`$3`), monthly
  (`$15`), and annual (`$100`) products in the App Store / Play Console and
  map them to the entitlement in `REVENUECAT_ENTITLEMENT_ID` (default:
  `premium`) and offering in `REVENUECAT_OFFERING_ID` (default: `default`).
