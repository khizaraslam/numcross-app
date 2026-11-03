-- NumCross Supabase schema (optional cloud sync)
-- Apply in the Supabase SQL editor or via supabase db push.
-- Core gameplay works fully offline without these tables.

create extension if not exists "pgcrypto";

-- Profiles (1:1 with auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Player',
  avatar_id text not null default 'boy',
  level int not null default 1 check (level >= 1),
  xp int not null default 0 check (xp >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_stats (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  games_played int not null default 0,
  games_completed int not null default 0,
  total_time_seconds int not null default 0,
  hints_used int not null default 0,
  mistakes int not null default 0,
  current_streak int not null default 0,
  best_streak int not null default 0,
  easy_completed int not null default 0,
  medium_completed int not null default 0,
  hard_completed int not null default 0,
  expert_completed int not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.daily_challenge_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  challenge_date date not null,
  puzzle_seed text not null,
  generator_version int not null default 1,
  difficulty text not null,
  time_seconds int not null default 0,
  mistakes int not null default 0,
  hints int not null default 0,
  score int not null default 0,
  completed_at timestamptz not null default now(),
  unique (user_id, challenge_date)
);

create table if not exists public.leaderboard_scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  period text not null check (period in ('daily', 'weekly', 'all_time')),
  period_key text not null,
  display_name text not null,
  avatar_id text not null default 'boy',
  score int not null default 0,
  completed_puzzles int not null default 0,
  best_streak int not null default 0,
  updated_at timestamptz not null default now(),
  unique (user_id, period, period_key)
);

create table if not exists public.achievements (
  id text primary key,
  title text not null,
  description text not null,
  target int not null default 1
);

create table if not exists public.user_achievements (
  user_id uuid not null references public.profiles (id) on delete cascade,
  achievement_id text not null references public.achievements (id) on delete cascade,
  progress int not null default 0,
  unlocked_at timestamptz,
  primary key (user_id, achievement_id)
);

create table if not exists public.remote_config (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.sync_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  synced_at timestamptz
);

alter table public.profiles enable row level security;
alter table public.user_stats enable row level security;
alter table public.daily_challenge_results enable row level security;
alter table public.leaderboard_scores enable row level security;
alter table public.user_achievements enable row level security;
alter table public.sync_events enable row level security;
alter table public.achievements enable row level security;
alter table public.remote_config enable row level security;

-- Own-row policies
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "stats_all_own" on public.user_stats
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "daily_all_own" on public.daily_challenge_results
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "leaderboard_select_public" on public.leaderboard_scores
  for select using (true);
create policy "leaderboard_upsert_own" on public.leaderboard_scores
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "user_achievements_own" on public.user_achievements
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "sync_events_own" on public.sync_events
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "achievements_read" on public.achievements
  for select using (true);

create policy "remote_config_read" on public.remote_config
  for select using (true);

-- Public leaderboard-safe view (no emails)
create or replace view public.leaderboard_public as
select
  period,
  period_key,
  display_name,
  avatar_id,
  score,
  completed_puzzles,
  best_streak,
  updated_at
from public.leaderboard_scores;
