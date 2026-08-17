# Stay Alive

Stay Alive is a Flutter nutrition tracker for daily healthy eating goals. The
app uses Appwrite for authentication, per-user progress storage, analytics,
history, gamification progress, and storage buckets.

## Architecture

The app follows feature-first Clean Architecture:

- `lib/core` — environment, Appwrite client setup, DI, errors, shared services
- `lib/features/auth` — Appwrite Account authentication and profile bootstrap
- `lib/features/daily_tracker` — daily serving checklist backed by Appwrite
- `lib/features/gamification` — XP, levels, streaks, and badges
- `lib/features/history` — Appwrite-backed progress summaries
- `lib/features/analytics` — Appwrite analytics event persistence
- `lib/features/subscription` — RevenueCat premium subscriptions and paywall

## Appwrite setup

Provision a project with:

```bash
APPWRITE_ENDPOINT=https://sfo.cloud.appwrite.io/v1 \
APPWRITE_PROJECT_ID=<project-id> \
APPWRITE_API_KEY=<server-api-key> \
python3 scripts/appwrite_provision.py
```

The script is idempotent and creates the database, collections, indexes,
storage buckets, and default Daily Dozen category documents. See
`docs/appwrite_backend_setup.md` for the full schema and OAuth setup notes.

## Home screen widgets

Android and iOS native widgets display today's completed servings, target,
percentage, streak, and level. iOS requires the App Group configured by
`DAILY_GOAL_WIDGET_APP_GROUP_ID` (default `group.com.example.stayAlive`) to be
created in the Apple Developer portal for signed device builds.

## Premium subscriptions

RevenueCat powers Premium access. Users can track daily fruit and vegetable
intake for free; full historical statistics require an active `premium`
entitlement. Configure these values per environment:

- `REVENUECAT_ANDROID_API_KEY`
- `REVENUECAT_IOS_API_KEY`
- `REVENUECAT_ENTITLEMENT_ID=premium`
- `REVENUECAT_OFFERING_ID=default`

In the RevenueCat dashboard, create weekly, monthly, and annual packages with
store prices of `$3`, `$15`, and `$100` respectively. The app displays the
RevenueCat store price when available and falls back to those labels while the
dashboard is not configured.

## Development

```bash
flutter pub get
flutter analyze
flutter test
```
