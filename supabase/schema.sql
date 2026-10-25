-- Схема для ok cake. Запустити один раз у Supabase → SQL Editor.

create table if not exists public.desserts (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('candy', 'cakes')),
  sort int not null default 0,
  name text not null default '',
  price text not null default '',
  size text not null default '',
  extra text not null default '',
  text text not null default '',
  items text[] not null default '{}',
  tags text[] not null default '{}',
  photos text[] not null default '{}',
  hidden boolean not null default false,
  updated_at timestamptz not null default now()
);

-- Хто може редагувати: лише користувачі з цієї таблиці.
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists desserts_touch on public.desserts;
create trigger desserts_touch before update on public.desserts
  for each row execute function public.touch_updated_at();

alter table public.desserts enable row level security;
alter table public.admins enable row level security;

-- Відвідувачі бачать лише неприховані десерти, адмін бачить усі.
drop policy if exists "public read" on public.desserts;
create policy "public read" on public.desserts
  for select using (not hidden or public.is_admin());

drop policy if exists "admin write" on public.desserts;
create policy "admin write" on public.desserts
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Фото: публічне читання, завантаження лише адміну.
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do update set public = true;

drop policy if exists "admin upload photos" on storage.objects;
create policy "admin upload photos" on storage.objects
  for insert to authenticated with check (bucket_id = 'photos' and public.is_admin());

drop policy if exists "admin update photos" on storage.objects;
create policy "admin update photos" on storage.objects
  for update to authenticated using (bucket_id = 'photos' and public.is_admin());

drop policy if exists "admin delete photos" on storage.objects;
create policy "admin delete photos" on storage.objects
  for delete to authenticated using (bucket_id = 'photos' and public.is_admin());

-- Після створення акаунта мами в Authentication → Users:
-- insert into public.admins (user_id) select id from auth.users where email = 'EMAIL_МАМИ';
