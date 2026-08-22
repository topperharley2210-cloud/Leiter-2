-- LeiterCheck V22 – Supabase setup
-- Run this once in Supabase Dashboard -> SQL Editor.
-- This schema protects each company's data with Row Level Security.
-- The browser uses ONLY the public anon/publishable key. Never expose service_role.

create extension if not exists pgcrypto;

create table if not exists public.leitercheck_organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  invite_code text not null unique default upper(substr(encode(gen_random_bytes(8),'hex'),1,10)),
  created_at timestamptz not null default now()
);

create table if not exists public.leitercheck_memberships (
  org_id uuid not null references public.leitercheck_organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','examiner')),
  display_name text not null,
  created_at timestamptz not null default now(),
  primary key (org_id,user_id)
);

create table if not exists public.leitercheck_state (
  org_id uuid primary key references public.leitercheck_organizations(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

create index if not exists leitercheck_memberships_user_idx
  on public.leitercheck_memberships(user_id);

alter table public.leitercheck_organizations enable row level security;
alter table public.leitercheck_memberships enable row level security;
alter table public.leitercheck_state enable row level security;

grant select on public.leitercheck_organizations to authenticated;
grant select on public.leitercheck_memberships to authenticated;
grant select, insert, update on public.leitercheck_state to authenticated;

drop policy if exists "members read organizations" on public.leitercheck_organizations;
create policy "members read organizations"
on public.leitercheck_organizations for select to authenticated
using (
  exists (
    select 1 from public.leitercheck_memberships m
    where m.org_id = id and m.user_id = (select auth.uid())
  )
);

drop policy if exists "members read memberships" on public.leitercheck_memberships;
create policy "members read memberships"
on public.leitercheck_memberships for select to authenticated
using (
  user_id = (select auth.uid())
  or exists (
    select 1 from public.leitercheck_memberships me
    where me.org_id = leitercheck_memberships.org_id
      and me.user_id = (select auth.uid())
      and me.role = 'admin'
  )
);

drop policy if exists "members read state" on public.leitercheck_state;
create policy "members read state"
on public.leitercheck_state for select to authenticated
using (
  exists (
    select 1 from public.leitercheck_memberships m
    where m.org_id = leitercheck_state.org_id
      and m.user_id = (select auth.uid())
  )
);

drop policy if exists "members insert state" on public.leitercheck_state;
create policy "members insert state"
on public.leitercheck_state for insert to authenticated
with check (
  exists (
    select 1 from public.leitercheck_memberships m
    where m.org_id = leitercheck_state.org_id
      and m.user_id = (select auth.uid())
  )
);

drop policy if exists "members update state" on public.leitercheck_state;
create policy "members update state"
on public.leitercheck_state for update to authenticated
using (
  exists (
    select 1 from public.leitercheck_memberships m
    where m.org_id = leitercheck_state.org_id
      and m.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.leitercheck_memberships m
    where m.org_id = leitercheck_state.org_id
      and m.user_id = (select auth.uid())
  )
);

create or replace function public.create_leitercheck_org(p_name text, p_display_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_org uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  insert into public.leitercheck_organizations(name, owner_id)
  values (trim(p_name), auth.uid())
  returning id into new_org;

  insert into public.leitercheck_memberships(org_id,user_id,role,display_name)
  values (new_org,auth.uid(),'admin',trim(p_display_name));

  insert into public.leitercheck_state(org_id,data,updated_by)
  values (new_org,'{}'::jsonb,auth.uid());

  return new_org;
end;
$$;

create or replace function public.join_leitercheck_org(p_invite_code text, p_display_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  target_org uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select id into target_org
  from public.leitercheck_organizations
  where upper(invite_code)=upper(trim(p_invite_code));

  if target_org is null then raise exception 'Invalid invite code'; end if;

  insert into public.leitercheck_memberships(org_id,user_id,role,display_name)
  values (target_org,auth.uid(),'examiner',trim(p_display_name))
  on conflict (org_id,user_id) do update set display_name=excluded.display_name;

  return target_org;
end;
$$;

grant execute on function public.create_leitercheck_org(text,text) to authenticated;
grant execute on function public.join_leitercheck_org(text,text) to authenticated;
