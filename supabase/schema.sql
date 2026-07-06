-- SCHEMA LENGKAP SUPABASE UNTUK APLIKASI E-TICKET HELPDESK
-- Jalankan file ini di Supabase SQL Editor.
--
-- File ini adalah sumber utama untuk backend Supabase:
-- tabel, function, trigger, RLS policy, storage, history, dan notifikasi.
--
-- Aman dijalankan ulang karena memakai:
-- - create table if not exists
-- - create or replace function
-- - drop trigger/policy if exists sebelum create ulang
--
-- Catatan:
-- File ini tidak menghapus data tiket/user yang sudah ada.
-- Kalau ingin benar-benar mulai dari nol, jalankan reset_full.sql dulu.

create extension if not exists pgcrypto;

-- =========================================================
-- 1. TABEL PROFIL
-- =========================================================
-- Supabase Auth menyimpan akun login di auth.users.
-- Tabel profiles menyimpan data tambahan aplikasi: nama, role, dan status aktif.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  role text not null default 'user' check (role in ('user', 'helpdesk', 'admin')),
  is_active boolean not null default true,
  created_at timestamp with time zone default now()
);

-- Kalau tabel sudah dibuat dari query lama, baris alter ini memastikan
-- kolom yang dipakai Flutter tetap tersedia.
alter table public.profiles add column if not exists full_name text;
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists role text not null default 'user';
alter table public.profiles add column if not exists is_active boolean not null default true;
alter table public.profiles add column if not exists created_at timestamp with time zone default now();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name')
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Helper kecil untuk membaca role user yang sedang login.
-- Dibuat security definer supaya policy RLS bisa memakainya tanpa muter-muter.
create or replace function public.get_my_role()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

-- =========================================================
-- 2. TABEL TIKET
-- =========================================================

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text check (category is null or category in ('hardware', 'software', 'network', 'other')),
  priority text default 'medium' check (priority in ('low', 'medium', 'high')),
  status text not null default 'open' check (status in ('open', 'assigned', 'in_progress', 'closed')),
  created_by uuid references public.profiles(id) not null,
  assigned_to uuid references public.profiles(id),
  is_deleted boolean not null default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  closed_at timestamp with time zone
);

alter table public.tickets add column if not exists title text;
alter table public.tickets add column if not exists description text;
alter table public.tickets add column if not exists category text;
alter table public.tickets add column if not exists priority text default 'medium';
alter table public.tickets add column if not exists status text not null default 'open';
alter table public.tickets add column if not exists created_by uuid references public.profiles(id);
alter table public.tickets add column if not exists assigned_to uuid references public.profiles(id);
alter table public.tickets add column if not exists is_deleted boolean not null default false;
alter table public.tickets add column if not exists created_at timestamp with time zone default now();
alter table public.tickets add column if not exists updated_at timestamp with time zone default now();
alter table public.tickets add column if not exists closed_at timestamp with time zone;

create table if not exists public.ticket_comments (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references public.tickets(id) on delete cascade not null,
  user_id uuid references public.profiles(id) not null,
  comment text not null,
  created_at timestamp with time zone default now()
);

create table if not exists public.ticket_attachments (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references public.tickets(id) on delete cascade not null,
  file_url text not null,
  uploaded_by uuid references public.profiles(id) not null,
  created_at timestamp with time zone default now()
);

create table if not exists public.ticket_history (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references public.tickets(id) on delete cascade not null,
  changed_by uuid references public.profiles(id) not null,
  old_status text,
  new_status text not null,
  note text,
  created_at timestamp with time zone default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) not null,
  ticket_id uuid references public.tickets(id) on delete cascade,
  message text not null,
  is_read boolean not null default false,
  created_at timestamp with time zone default now()
);

-- =========================================================
-- 3. TRIGGER TIKET
-- =========================================================
-- Trigger ini membuat backend tetap rapi:
-- - updated_at berubah otomatis saat tiket di-update.
-- - closed_at terisi saat status menjadi closed.
-- - riwayat status masuk ke ticket_history.
-- - helpdesk hanya boleh mengubah status tiket yang ditugaskan.
-- - notifikasi dikirim ke role yang sesuai.

create or replace function public.notify_admins(ticket_id uuid, message text, actor_id uuid default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (user_id, ticket_id, message)
  select p.id, notify_admins.ticket_id, notify_admins.message
  from public.profiles p
  where p.role = 'admin'
    and p.is_active = true
    and (actor_id is null or p.id <> actor_id);
end;
$$;

create or replace function public.handle_ticket_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.get_my_role() <> 'admin' then
    if new.title is distinct from old.title
      or new.description is distinct from old.description
      or new.category is distinct from old.category
      or new.priority is distinct from old.priority
      or new.created_by is distinct from old.created_by
      or new.assigned_to is distinct from old.assigned_to
      or new.is_deleted is distinct from old.is_deleted then
      raise exception 'Helpdesk hanya boleh mengubah status tiket';
    end if;
  end if;

  new.updated_at = now();

  if new.status = 'closed' and old.status is distinct from 'closed' then
    new.closed_at = now();
  end if;

  if new.status is distinct from old.status then
    insert into public.ticket_history (ticket_id, changed_by, old_status, new_status)
    values (new.id, auth.uid(), old.status, new.status);
  end if;

  return new;
end;
$$;

drop trigger if exists on_ticket_status_update on public.tickets;
drop trigger if exists on_ticket_update on public.tickets;
create trigger on_ticket_update
  before update on public.tickets
  for each row execute procedure public.handle_ticket_update();

create or replace function public.handle_ticket_created_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Saat user membuat tiket baru, semua admin aktif perlu tahu.
  perform public.notify_admins(
    new.id,
    'Tiket baru "' || new.title || '" telah dibuat',
    new.created_by
  );

  return new;
end;
$$;

drop trigger if exists on_ticket_created_notify on public.tickets;
create trigger on_ticket_created_notify
  after insert on public.tickets
  for each row execute procedure public.handle_ticket_created_notification();

create or replace function public.handle_ticket_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Saat admin assign tiket, helpdesk yang ditugaskan harus dapat notifikasi.
  if new.assigned_to is not null and new.assigned_to is distinct from old.assigned_to then
    insert into public.notifications (user_id, ticket_id, message)
    values (new.assigned_to, new.id, 'Tiket "' || new.title || '" ditugaskan kepada kamu');
  end if;

  -- Saat status berubah, pembuat tiket harus dapat notifikasi.
  -- Kalau pembuat tiket adalah orang yang mengubah status, tidak perlu notifikasi ke diri sendiri.
  if old.status is distinct from new.status then
    if new.created_by is not null and (auth.uid() is null or new.created_by <> auth.uid()) then
      insert into public.notifications (user_id, ticket_id, message)
      values (new.created_by, new.id, 'Status tiket "' || new.title || '" berubah menjadi ' || new.status);
    end if;

    -- Admin lain juga perlu tahu perkembangan tiket, terutama saat helpdesk mengubah status.
    perform public.notify_admins(
      new.id,
      'Status tiket "' || new.title || '" berubah menjadi ' || new.status,
      auth.uid()
    );
  end if;

  return new;
end;
$$;

drop trigger if exists on_ticket_status_notify on public.tickets;
create trigger on_ticket_status_notify
  after update on public.tickets
  for each row execute procedure public.handle_ticket_notification();

create or replace function public.handle_comment_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  ticket_record public.tickets%rowtype;
  sender_name text;
begin
  select * into ticket_record
  from public.tickets
  where id = new.ticket_id;

  select coalesce(full_name, email, 'Seseorang') into sender_name
  from public.profiles
  where id = new.user_id;

  -- Kalau user/helpdesk/admin memberi komentar, pembuat tiket perlu tahu,
  -- kecuali pembuat tiket adalah pengirim komentar itu sendiri.
  if ticket_record.created_by is not null and ticket_record.created_by <> new.user_id then
    insert into public.notifications (user_id, ticket_id, message)
    values (
      ticket_record.created_by,
      new.ticket_id,
      sender_name || ' menambahkan komentar pada tiket "' || ticket_record.title || '"'
    );
  end if;

  -- Helpdesk yang ditugaskan juga perlu tahu jika ada komentar baru,
  -- kecuali komentar itu dikirim oleh helpdesk tersebut.
  if ticket_record.assigned_to is not null and ticket_record.assigned_to <> new.user_id then
    insert into public.notifications (user_id, ticket_id, message)
    values (
      ticket_record.assigned_to,
      new.ticket_id,
      sender_name || ' menambahkan komentar pada tiket "' || ticket_record.title || '"'
    );
  end if;

  -- Admin aktif juga mendapat info komentar baru, kecuali admin itu pengirimnya.
  perform public.notify_admins(
    new.ticket_id,
    sender_name || ' menambahkan komentar pada tiket "' || ticket_record.title || '"',
    new.user_id
  );

  return new;
end;
$$;

drop trigger if exists on_comment_created_notify on public.ticket_comments;
create trigger on_comment_created_notify
  after insert on public.ticket_comments
  for each row execute procedure public.handle_comment_notification();

-- =========================================================
-- 4. ROW LEVEL SECURITY
-- =========================================================
-- RLS adalah pagar backend.
-- Flutter boleh menyembunyikan tombol, tapi Supabase tetap wajib menolak akses ilegal.

alter table public.profiles enable row level security;
alter table public.tickets enable row level security;
alter table public.ticket_comments enable row level security;
alter table public.ticket_attachments enable row level security;
alter table public.ticket_history enable row level security;
alter table public.notifications enable row level security;

-- Drop policy lama dan policy baru agar script aman dijalankan ulang.
drop policy if exists "User bisa baca profil sendiri, admin baca semua" on public.profiles;
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
on public.profiles for select
using (id = auth.uid() or public.get_my_role() = 'admin');

drop policy if exists "User bisa update profil sendiri kecuali role dan is_active" on public.profiles;
drop policy if exists "profiles_update_admin_only" on public.profiles;
create policy "profiles_update_admin_only"
on public.profiles for update
using (public.get_my_role() = 'admin')
with check (public.get_my_role() = 'admin');

drop policy if exists "Lihat tiket sesuai role" on public.tickets;
drop policy if exists "tickets_select_by_role" on public.tickets;
create policy "tickets_select_by_role"
on public.tickets for select
using (
  is_deleted = false and (
    created_by = auth.uid()
    or assigned_to = auth.uid()
    or public.get_my_role() = 'admin'
  )
);

drop policy if exists "Semua role bisa membuat tiket atas nama sendiri" on public.tickets;
drop policy if exists "tickets_insert_own" on public.tickets;
create policy "tickets_insert_own"
on public.tickets for insert
with check (created_by = auth.uid());

drop policy if exists "Update tiket oleh helpdesk yang ditugaskan atau admin" on public.tickets;
drop policy if exists "Hanya admin yang bisa soft delete tiket" on public.tickets;
drop policy if exists "tickets_update_admin_or_assigned_helpdesk" on public.tickets;
create policy "tickets_update_admin_or_assigned_helpdesk"
on public.tickets for update
using (
  public.get_my_role() = 'admin'
  or assigned_to = auth.uid()
)
with check (
  public.get_my_role() = 'admin'
  or assigned_to = auth.uid()
);

drop policy if exists "Lihat komentar jika punya akses ke tiketnya" on public.ticket_comments;
drop policy if exists "comments_select_if_ticket_accessible" on public.ticket_comments;
create policy "comments_select_if_ticket_accessible"
on public.ticket_comments for select
using (
  exists (
    select 1 from public.tickets t
    where t.id = ticket_id
    and (t.created_by = auth.uid() or t.assigned_to = auth.uid() or public.get_my_role() = 'admin')
  )
);

drop policy if exists "Tambah komentar jika punya akses ke tiketnya" on public.ticket_comments;
drop policy if exists "comments_insert_if_ticket_accessible" on public.ticket_comments;
create policy "comments_insert_if_ticket_accessible"
on public.ticket_comments for insert
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.tickets t
    where t.id = ticket_id
    and t.status <> 'closed'
    and (t.created_by = auth.uid() or t.assigned_to = auth.uid() or public.get_my_role() = 'admin')
  )
);

drop policy if exists "Lihat attachment jika punya akses ke tiketnya" on public.ticket_attachments;
drop policy if exists "attachments_select_if_ticket_accessible" on public.ticket_attachments;
create policy "attachments_select_if_ticket_accessible"
on public.ticket_attachments for select
using (
  exists (
    select 1 from public.tickets t
    where t.id = ticket_id
    and (t.created_by = auth.uid() or t.assigned_to = auth.uid() or public.get_my_role() = 'admin')
  )
);

drop policy if exists "Upload attachment jika punya akses ke tiketnya" on public.ticket_attachments;
drop policy if exists "attachments_insert_if_ticket_accessible" on public.ticket_attachments;
create policy "attachments_insert_if_ticket_accessible"
on public.ticket_attachments for insert
with check (
  uploaded_by = auth.uid()
  and exists (
    select 1 from public.tickets t
    where t.id = ticket_id
    and (t.created_by = auth.uid() or t.assigned_to = auth.uid() or public.get_my_role() = 'admin')
  )
);

drop policy if exists "Lihat history jika punya akses ke tiketnya" on public.ticket_history;
drop policy if exists "history_select_if_ticket_accessible" on public.ticket_history;
create policy "history_select_if_ticket_accessible"
on public.ticket_history for select
using (
  exists (
    select 1 from public.tickets t
    where t.id = ticket_id
    and (t.created_by = auth.uid() or t.assigned_to = auth.uid() or public.get_my_role() = 'admin')
  )
);

drop policy if exists "User hanya baca notifikasi miliknya sendiri" on public.notifications;
drop policy if exists "notifications_select_own" on public.notifications;
create policy "notifications_select_own"
on public.notifications for select
using (user_id = auth.uid());

drop policy if exists "User bisa update status baca notifikasi miliknya" on public.notifications;
drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own"
on public.notifications for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- =========================================================
-- 5. STORAGE ATTACHMENT
-- =========================================================
-- Untuk project kuliah/demo, bucket dibuat public supaya Image.network(file_url)
-- di Flutter langsung bisa menampilkan gambar.
-- Kalau mau versi lebih aman, bucket bisa dibuat private dan Flutter diganti pakai signed URL.

insert into storage.buckets (id, name, public)
values ('ticket-attachments', 'ticket-attachments', true)
on conflict (id) do update set public = true;

drop policy if exists "User bisa upload attachment ke folder sendiri" on storage.objects;
drop policy if exists "storage_insert_ticket_attachments" on storage.objects;
create policy "storage_insert_ticket_attachments"
on storage.objects for insert
with check (
  bucket_id = 'ticket-attachments'
  and auth.uid() is not null
);

drop policy if exists "User bisa lihat attachment yang relevan" on storage.objects;
drop policy if exists "storage_select_ticket_attachments" on storage.objects;
create policy "storage_select_ticket_attachments"
on storage.objects for select
using (
  bucket_id = 'ticket-attachments'
  and auth.uid() is not null
);
