# Stay Alive

Stay Alive is a Flutter nutrition tracker for daily healthy eating goals. The
app uses Supabase for authentication, per-user progress storage, analytics,
history and gamification progress.

## Architecture

The app follows feature-first Clean Architecture:

- `lib/core` — environment, Supabase wiring, DI, errors, shared services
- `lib/features/auth` — Supabase Auth (email, Google/Apple OAuth, guest)
- `lib/features/daily_tracker` — daily serving checklist backed by Postgres
- `lib/features/gamification` — XP, levels, streaks, and badges
- `lib/features/history` — progress summaries over `daily_logs`
- `lib/features/analytics` — analytics event persistence
- `lib/features/subscription` — RevenueCat premium subscriptions and paywall

## Supabase setup

The whole backend is reproducible from `supabase/` (schema, RLS, seed, edge
functions):

```bash
supabase start            # local stack; the dev flavor uses it with zero config
supabase db reset         # applies migrations + Daily Dozen category seed
supabase functions serve  # delete_user + ai_coach
```

For a hosted project: `supabase link`, `db push`, `functions deploy`. Full
runbook and dashboard checklist: `docs/supabase_backend_setup.md`.

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
