-- Puzzle Arcade accounts: username + password, ratings saved per player.
-- Paste this whole file into Supabase > SQL Editor and press Run. Safe to run again.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.arcade_players (
  username   text primary key check (username ~ '^[a-z0-9_]{3,20}$'),
  pass_hash  text not null,
  progress   jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.arcade_sessions (
  token      uuid primary key default gen_random_uuid(),
  username   text not null references public.arcade_players(username) on delete cascade,
  created_at timestamptz not null default now()
);

-- Nobody reads the tables directly; the app only talks to the functions below.
alter table public.arcade_players  enable row level security;
alter table public.arcade_sessions enable row level security;
revoke all on public.arcade_players, public.arcade_sessions from anon, authenticated;

create or replace function public.arcade_register(p_username text, p_password text)
returns json language plpgsql security definer set search_path = public, extensions as $$
declare u text := lower(trim(p_username)); t uuid;
begin
  if u !~ '^[a-z0-9_]{3,20}$' then raise exception 'Username must be 3–20 letters, numbers or _.'; end if;
  if length(coalesce(p_password,'')) < 6 then raise exception 'Password must be at least 6 characters.'; end if;
  if exists (select 1 from arcade_players where username = u) then raise exception 'That username is taken.'; end if;
  insert into arcade_players (username, pass_hash) values (u, crypt(p_password, gen_salt('bf')));
  insert into arcade_sessions (username) values (u) returning token into t;
  return json_build_object('token', t, 'username', u, 'progress', '{}'::jsonb);
end $$;

create or replace function public.arcade_login(p_username text, p_password text)
returns json language plpgsql security definer set search_path = public, extensions as $$
declare u text := lower(trim(p_username)); h text; pr jsonb; t uuid;
begin
  select pass_hash, progress into h, pr from arcade_players where username = u;
  if h is null or h <> crypt(coalesce(p_password,''), h) then
    perform pg_sleep(0.5);
    raise exception 'Wrong username or password.';
  end if;
  insert into arcade_sessions (username) values (u) returning token into t;
  return json_build_object('token', t, 'username', u, 'progress', pr);
end $$;

create or replace function public.arcade_load(p_token uuid)
returns json language plpgsql security definer set search_path = public, extensions as $$
declare u text; pr jsonb;
begin
  select p.username, p.progress into u, pr
    from arcade_sessions s join arcade_players p on p.username = s.username where s.token = p_token;
  if u is null then raise exception 'Session expired. Log in again.'; end if;
  return json_build_object('username', u, 'progress', pr);
end $$;

create or replace function public.arcade_save(p_token uuid, p_progress jsonb)
returns json language plpgsql security definer set search_path = public, extensions as $$
declare u text;
begin
  if pg_column_size(p_progress) > 20000 then raise exception 'Progress data is too large.'; end if;
  update arcade_players set progress = p_progress, updated_at = now()
   where username = (select username from arcade_sessions where token = p_token)
   returning username into u;
  if u is null then raise exception 'Session expired. Log in again.'; end if;
  return json_build_object('ok', true);
end $$;

create or replace function public.arcade_logout(p_token uuid)
returns void language sql security definer set search_path = public as $$
  delete from arcade_sessions where token = p_token;
$$;

grant execute on function public.arcade_register(text, text), public.arcade_login(text, text),
  public.arcade_load(uuid), public.arcade_save(uuid, jsonb), public.arcade_logout(uuid) to anon, authenticated;
