-- LocalGrow AI starter schema.
-- Run this in Supabase SQL Editor after creating a project.
-- Enable RLS and scope every customer record to the authenticated owner.

create extension if not exists pgcrypto;

create table if not exists public.business_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  business_name text not null default 'My Business',
  category text not null default 'Local Business',
  location text,
  language text not null default 'English',
  whatsapp_number text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  phone text not null,
  email text,
  service text,
  last_visit date,
  follow_up_date date,
  consent boolean not null default false,
  consent_recorded_at timestamptz,
  opted_out_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists customers_user_id_idx on public.customers(user_id);
create index if not exists customers_follow_up_idx on public.customers(user_id, follow_up_date);

create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  campaign_type text not null default 'promotional',
  message_text text,
  status text not null default 'draft' check (status in ('draft','scheduled','sending','sent','paused','failed')),
  scheduled_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.automations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  trigger_type text not null default 'days_after_last_visit',
  trigger_days integer not null default 30 check (trigger_days between 1 and 365),
  send_time time not null default '11:00',
  timezone text not null default 'Asia/Kolkata',
  enabled boolean not null default false,
  status text not null default 'draft' check (status in ('draft','active','paused','failed')),
  message_template_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.message_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  customer_id uuid references public.customers(id) on delete set null,
  campaign_id uuid references public.campaigns(id) on delete set null,
  automation_id uuid references public.automations(id) on delete set null,
  provider_message_id text,
  status text not null default 'queued' check (status in ('queued','sent','delivered','read','failed','skipped')),
  error_message text,
  idempotency_key text unique,
  scheduled_at timestamptz,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.business_profiles enable row level security;
alter table public.customers enable row level security;
alter table public.campaigns enable row level security;
alter table public.automations enable row level security;
alter table public.message_logs enable row level security;

drop policy if exists "profile owner can read" on public.business_profiles;
create policy "profile owner can read" on public.business_profiles for select to authenticated using (auth.uid() = user_id);
drop policy if exists "profile owner can insert" on public.business_profiles;
create policy "profile owner can insert" on public.business_profiles for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "profile owner can update" on public.business_profiles;
create policy "profile owner can update" on public.business_profiles for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "customer owner access" on public.customers;
create policy "customer owner access" on public.customers for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "campaign owner access" on public.campaigns;
create policy "campaign owner access" on public.campaigns for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "automation owner access" on public.automations;
create policy "automation owner access" on public.automations for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "message log owner access" on public.message_logs;
create policy "message log owner access" on public.message_logs for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- NOTE: This schema intentionally does not expose Meta/AI secrets to clients.
-- Configure scheduled execution separately. Do not activate sending until consent,
-- opt-out handling, approved WhatsApp templates, and idempotency are tested.
