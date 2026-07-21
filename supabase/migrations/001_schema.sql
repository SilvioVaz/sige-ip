create extension if not exists pgcrypto;

create table if not exists public.organizations (
 id uuid primary key default gen_random_uuid(), name text not null, created_at timestamptz not null default now()
);
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 organization_id uuid not null references public.organizations(id) on delete cascade,
 full_name text, role text not null default 'owner' check(role in ('owner','admin','manager','viewer')),
 created_at timestamptz not null default now()
);
create table if not exists public.app_states (
 organization_id uuid primary key references public.organizations(id) on delete cascade,
 data jsonb not null default '{}'::jsonb,
 version bigint not null default 1,
 updated_by uuid references auth.users(id), updated_at timestamptz not null default now()
);
create table if not exists public.app_backups (
 id bigint generated always as identity primary key, organization_id uuid not null references public.organizations(id) on delete cascade,
 data jsonb not null, reason text, created_by uuid references auth.users(id), created_at timestamptz not null default now()
);
create table if not exists public.google_sheet_sources (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 spreadsheet_id text not null, spreadsheet_url text not null, enabled boolean not null default true,
 last_synced_at timestamptz, created_at timestamptz not null default now(), unique(organization_id,spreadsheet_id)
);
create table if not exists public.strategic_items (
 id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id) on delete cascade,
 source_key text not null, sheet_name text not null, source_row int not null, record_type text default 'Tarefa',
 objective text, axis text, title text, owner text, company text, status text, due_date date, next_review date,
 kpi text, priority text, notes text, raw jsonb not null default '{}'::jsonb, source_updated_at timestamptz default now(),
 unique(organization_id,source_key)
);
create table if not exists public.sync_logs (
 id bigint generated always as identity primary key, organization_id uuid not null references public.organizations(id) on delete cascade,
 status text not null, item_count int default 0, details jsonb default '{}'::jsonb, created_at timestamptz not null default now()
);

create or replace function public.current_org_id() returns uuid language sql stable security definer set search_path=public as $$
 select organization_id from public.profiles where id=auth.uid()
$$;

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.app_states enable row level security;
alter table public.app_backups enable row level security;
alter table public.google_sheet_sources enable row level security;
alter table public.strategic_items enable row level security;
alter table public.sync_logs enable row level security;

create policy "org members read organization" on public.organizations for select using(id=public.current_org_id());
create policy "profile own org read" on public.profiles for select using(organization_id=public.current_org_id());
create policy "profile own update" on public.profiles for update using(id=auth.uid());
create policy "state org all" on public.app_states for all using(organization_id=public.current_org_id()) with check(organization_id=public.current_org_id());
create policy "backup org all" on public.app_backups for all using(organization_id=public.current_org_id()) with check(organization_id=public.current_org_id());
create policy "source org all" on public.google_sheet_sources for all using(organization_id=public.current_org_id()) with check(organization_id=public.current_org_id());
create policy "items org read" on public.strategic_items for select using(organization_id=public.current_org_id());
create policy "logs org read" on public.sync_logs for select using(organization_id=public.current_org_id());

grant usage on schema public to authenticated;
grant select on public.organizations,public.profiles,public.strategic_items,public.sync_logs to authenticated;
grant select,insert,update,delete on public.app_states,public.app_backups,public.google_sheet_sources to authenticated;
grant usage,select on all sequences in schema public to authenticated;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
declare oid uuid;
begin
 insert into public.organizations(name) values(coalesce(new.raw_user_meta_data->>'organization_name','SIGE IP')) returning id into oid;
 insert into public.profiles(id,organization_id,full_name,role) values(new.id,oid,coalesce(new.raw_user_meta_data->>'full_name',new.email),'owner');
 return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter publication supabase_realtime add table public.app_states;

create or replace function public.prune_old_backups() returns void language sql security definer set search_path=public as $$
 delete from public.app_backups b where b.id in (
  select id from (select id,row_number() over(partition by organization_id order by created_at desc) rn from public.app_backups) x where rn>30
 );
$$;
