# Supabase backend setup

Stay Alive runs on Supabase: GoTrue auth, Postgres (via PostgREST) and Deno
edge functions. Everything server-side lives in `supabase/` — schema, RLS,
seed data and both functions — so the whole backend is reproducible from the
repo.

## 1. Local development

Prereqs: Docker + the Supabase CLI (`brew install supabase/tap/supabase`).

```sh
supabase start        # boots Postgres, GoTrue, PostgREST, Studio
supabase db reset     # applies supabase/migrations + category seed
supabase functions serve   # serves delete_user + ai_coach with hot reload
```

The app's dev flavor defaults to the local stack (`http://127.0.0.1:54321` +
the public demo anon key) with **no configuration at all** — `flutter run
--flavor dev -t lib/main_dev.dart` just works. The Android emulator reaches
the stack via `http://10.0.2.2:54321`; set `SUPABASE_URL` in
`assets/env/app.env` (gitignored) or via `--dart-define` for that case.

Studio: <http://127.0.0.1:54323>.

### AI coach locally

The `ai_coach` function answers `503 llm_unavailable` without an OpenAI key,
and the app degrades to `CoachLocalFallback`. To test the live path, put
`OPENAI_API_KEY=sk-...` into `supabase/functions/.env` and run
`supabase functions serve --env-file supabase/functions/.env`.

## 2. Cloud project (production / hosted dev)

One-time, from the repo root:

```sh
supabase login
supabase link --project-ref <ref>       # create the project at supabase.com first
supabase db push                        # applies migrations + seed
supabase functions deploy delete_user
supabase functions deploy ai_coach
supabase secrets set OPENAI_API_KEY=sk-...   # only needed for the live coach
```

Then the dashboard checklist (Authentication → Sign In / Up):

1. **Email**: keep "Confirm email" **OFF** — the app expects instant login
   after sign-up and throws a descriptive error if a session is withheld.
2. **Anonymous sign-ins**: **ON** (the guest login button uses them).
3. **Google / Apple providers**: enable and paste client ids + secrets
   (Apple: Services ID + key; Google: OAuth client). Bundle id is
   `com.gaussdev.stayalive`.
4. **URL configuration**: add `stayalive://login-callback` to Redirect URLs.

Finally, point builds at the project: `SUPABASE_URL=https://<ref>.supabase.co`
and `SUPABASE_ANON_KEY=<publishable key>` go into `scripts/release.env`
(local prod builds) and the `SUPABASE_URL` / `SUPABASE_ANON_KEY` GitHub
secrets (CI builds). Production **fails closed**: without injected values the
app throws at bootstrap instead of silently using a dev backend.

## 3. Schema

Single migration `supabase/migrations/*_initial_schema.sql`. Tables
(`public` schema, RLS enabled on all):

| Table | Ownership | Notes |
|---|---|---|
| `profiles` | `id` = auth user id | one row per auth user, upserted on sign-in |
| `category_definitions` | public read | seeded with the 12 Daily Dozen rows |
| `daily_logs` | `user_id`, unique `(user_id, log_date)` | one log per user per day |
| `daily_log_items` | `user_id`, unique `(log_id, category_id)` | denormalized category fields |
| `gamification_profiles` | `user_id` PK | arrays for badges/dates |
| `gamification_events` | `user_id`, unique `(user_id, event_type, log_date)` | `inserted_at` = server time |
| `analytics_events` | insert-only; `user_id` nullable | anon inserts allowed with null user |
| `ai_interactions` | service-role only | written by the ai_coach function |

Every user-owned table references `auth.users(id) ON DELETE CASCADE`, so
account deletion is: `delete_user` function removes the auth record → all
rows vanish. There is no client-side sweep anymore.

Schema changes: edit via `supabase db query`/Studio against the local stack,
then `supabase db pull <name> --local` to generate the next migration (or
hand-write one with `supabase migration new <name>`). Run
`supabase db advisors` before committing.

## 4. Functions

- **`delete_user`** — verifies the caller's JWT, `auth.admin.deleteUser`.
  A session can only delete itself. 404 (already gone) counts as success.
- **`ai_coach`** — OpenAI proxy (`OPENAI_MODEL`, default `gpt-4o-mini`).
  Premium gate on `chat` / `weeklyInsight` / `personalizeChallenge`;
  `503` without `OPENAI_API_KEY`; audits into `ai_interactions` via the
  service role. The Flutter client treats **any** failure as "use the local
  fallback".

Both have `verify_jwt = true` — unauthenticated calls are rejected at the
gateway.

## 5. Native widget bridge

Unchanged by the migration: `DailyGoalWidgetService` writes
`daily_goal_completed/target/percentage/date/streak/level` through
`home_widget` under App Group `group.com.gaussdev.stayalive`.
