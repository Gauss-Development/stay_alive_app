-- Stay Alive — initial Supabase schema.
-- Ported from the Appwrite provisioning script (scripts/appwrite_provision.py, deleted).
-- Column names intentionally match the old Appwrite attribute names so the Dart
-- model mapping stays mechanical (including the misleading `*_json` array names).
--
-- Ownership model: real `user_id` FK columns + RLS replace Appwrite's per-document
-- permissions. `on delete cascade` from auth.users replaces the client-side
-- account-deletion sweep (and fixes rows that previously survived deletion).

-- ---------------------------------------------------------------------------
-- profiles — was Appwrite `users` collection (document id == auth user id)
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  name text not null,
  avatar_url text,
  onboarding_completed boolean not null default false,
  units_preference text not null default 'metric',
  locale text not null default 'en',
  age integer,
  gender text,
  preferred_diet text,
  height_cm integer,
  weight_kg double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- ---------------------------------------------------------------------------
-- category_definitions — public reference data (id == category slug)
-- ---------------------------------------------------------------------------
create table public.category_definitions (
  id text primary key,
  category_id text not null unique,
  title text not null,
  description text not null,
  icon_key text not null,
  target_count integer not null,
  display_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index category_definitions_active_order_idx
  on public.category_definitions (is_active, display_order);

alter table public.category_definitions enable row level security;

create policy "category_definitions_public_read" on public.category_definitions
  for select to anon, authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- daily_logs — was doc id `{userId}_{yyyy-MM-dd}`; now (user_id, log_date) unique
-- ---------------------------------------------------------------------------
create table public.daily_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  log_date date not null,
  completion_percentage double precision not null default 0,
  total_completed integer not null default 0,
  total_target integer not null default 0,
  is_fully_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, log_date)
);

alter table public.daily_logs enable row level security;

create policy "daily_logs_select_own" on public.daily_logs
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "daily_logs_insert_own" on public.daily_logs
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "daily_logs_update_own" on public.daily_logs
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- daily_log_items — was doc id hash(`item|{logId}|{categoryId}`); now (log_id, category_id) unique
-- Category fields stay denormalized onto the item, as before.
-- ---------------------------------------------------------------------------
create table public.daily_log_items (
  id uuid primary key default gen_random_uuid(),
  log_id uuid not null references public.daily_logs (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  category_id text not null,
  category_title text not null,
  description text,
  icon_key text,
  target_count integer not null default 0,
  display_order integer not null default 0,
  is_active boolean not null default true,
  completed_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (log_id, category_id)
);

create index daily_log_items_user_id_idx on public.daily_log_items (user_id);

alter table public.daily_log_items enable row level security;

create policy "daily_log_items_select_own" on public.daily_log_items
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "daily_log_items_insert_own" on public.daily_log_items
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "daily_log_items_update_own" on public.daily_log_items
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- gamification_profiles — was doc id == user id
-- `*_json` columns are arrays of 'yyyy-MM-dd' strings (legacy naming kept on purpose).
-- ---------------------------------------------------------------------------
create table public.gamification_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  xp integer not null default 0,
  level integer not null default 1,
  current_streak integer not null default 0,
  best_streak integer not null default 0,
  completed_days integer not null default 0,
  last_completed_date text,
  badges text[] not null default '{}',
  activity_streak integer not null default 0,
  total_categories_completed integer not null default 0,
  streak_freezes_remaining integer not null default 0,
  streak_freezes_used text[] not null default '{}',
  completed_dates_json text[] not null default '{}',
  early_log_dates_json text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.gamification_profiles enable row level security;

create policy "gamification_profiles_select_own" on public.gamification_profiles
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "gamification_profiles_insert_own" on public.gamification_profiles
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "gamification_profiles_update_own" on public.gamification_profiles
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- gamification_events
-- `created_at` is client-written and backdated for badge events; `inserted_at`
-- is the server insert time and preserves the old `$createdAt` ordering.
-- The unique constraint hardens the app's read-then-insert dedup (one event
-- per user/type/date); inserts use ON CONFLICT DO NOTHING.
-- ---------------------------------------------------------------------------
create table public.gamification_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  event_type text not null,
  xp_delta integer not null default 0,
  log_date text,
  metadata_json text,
  created_at timestamptz not null default now(),
  inserted_at timestamptz not null default now(),
  unique nulls not distinct (user_id, event_type, log_date)
);

create index gamification_events_user_inserted_idx
  on public.gamification_events (user_id, inserted_at desc);

alter table public.gamification_events enable row level security;

create policy "gamification_events_select_own" on public.gamification_events
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "gamification_events_insert_own" on public.gamification_events
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- analytics_events — write-only from the client; user_id null = logged-out event
-- ---------------------------------------------------------------------------
create table public.analytics_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid default auth.uid() references auth.users (id) on delete cascade,
  event_name text not null,
  screen_name text,
  metadata_json text,
  created_at timestamptz not null default now()
);

create index analytics_events_user_id_idx on public.analytics_events (user_id);

alter table public.analytics_events enable row level security;

create policy "analytics_events_insert_own" on public.analytics_events
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "analytics_events_insert_anon" on public.analytics_events
  for insert to anon
  with check (user_id is null);

-- ---------------------------------------------------------------------------
-- ai_interactions — audit rows written by the ai_coach edge function
-- (service role only; RLS on with no policies keeps clients out).
-- ---------------------------------------------------------------------------
create table public.ai_interactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  mode text not null,
  from_fallback boolean not null default false,
  created_at timestamptz not null default now()
);

create index ai_interactions_user_created_idx
  on public.ai_interactions (user_id, created_at);

alter table public.ai_interactions enable row level security;

-- ---------------------------------------------------------------------------
-- Grants — tables are not auto-exposed to Data API roles; grant exactly the
-- verbs that have RLS policies (RLS filters rows, grants filter verbs).
-- ---------------------------------------------------------------------------
grant usage on schema public to anon, authenticated;

grant select, insert, update on public.profiles to authenticated;
grant select on public.category_definitions to anon, authenticated;
grant select, insert, update on public.daily_logs to authenticated;
grant select, insert, update on public.daily_log_items to authenticated;
grant select, insert, update on public.gamification_profiles to authenticated;
grant select, insert on public.gamification_events to authenticated;
grant insert on public.analytics_events to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Seed: the 12 Daily Dozen categories (mirrors the bundled Dart fallback list
-- in daily_tracker_remote_data_source.dart — keep the two in sync).
-- ---------------------------------------------------------------------------
insert into public.category_definitions
  (id, category_id, title, description, icon_key, target_count, display_order, is_active)
values
  ('beans', 'beans', 'Beans / Legumes', 'Track servings of beans and legumes', 'beans', 3, 1, true),
  ('berries', 'berries', 'Berries', 'Track servings of berries', 'berries', 1, 2, true),
  ('fruits', 'fruits', 'Fruits', 'Track fruit servings', 'fruits', 3, 3, true),
  ('cruciferous_vegetables', 'cruciferous_vegetables', 'Cruciferous Vegetables', 'Track cruciferous veggie servings', 'cruciferous_vegetables', 1, 4, true),
  ('greens', 'greens', 'Greens', 'Track leafy greens servings', 'greens', 2, 5, true),
  ('other_vegetables', 'other_vegetables', 'Other Vegetables', 'Track other vegetable servings', 'other_vegetables', 2, 6, true),
  ('flaxseeds', 'flaxseeds', 'Flaxseeds', 'Track flaxseed servings', 'flaxseeds', 1, 7, true),
  ('nuts', 'nuts', 'Nuts', 'Track nuts servings', 'nuts', 1, 8, true),
  ('spices', 'spices', 'Spices', 'Track turmeric/spice servings', 'spices', 1, 9, true),
  ('whole_grains', 'whole_grains', 'Whole Grains', 'Track whole grain servings', 'whole_grains', 3, 10, true),
  ('beverages', 'beverages', 'Beverages', 'Track healthy beverage goals', 'beverages', 5, 11, true),
  ('exercise', 'exercise', 'Exercise', 'Track exercise sessions', 'exercise', 1, 12, true)
on conflict (id) do nothing;
