-- RESET TOTAL SUPABASE UNTUK PROJECT E-TICKET
-- PERINGATAN:
-- File ini menghapus data aplikasi, file attachment, dan akun auth.users.
-- Jalankan hanya kalau kamu benar-benar ingin mulai dari nol.
--
-- Urutan pakai:
-- 1. Jalankan supabase/reset_full.sql
-- 2. Jalankan supabase/schema.sql
-- 3. Register ulang akun dari aplikasi
-- 4. Ubah role akun pertama menjadi admin di tabel profiles

-- =========================================================
-- 1. MATIKAN TRIGGER LAMA
-- =========================================================
-- Trigger dihapus dulu supaya function dan tabel bisa dibersihkan tanpa nyangkut.

drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists on_ticket_status_update on public.tickets;
drop trigger if exists on_ticket_update on public.tickets;
drop trigger if exists on_ticket_created_notify on public.tickets;
drop trigger if exists on_ticket_status_notify on public.tickets;
drop trigger if exists on_comment_created_notify on public.ticket_comments;

-- =========================================================
-- 2. HAPUS POLICY STORAGE
-- =========================================================

drop policy if exists "User bisa upload attachment ke folder sendiri" on storage.objects;
drop policy if exists "User bisa lihat attachment yang relevan" on storage.objects;
drop policy if exists "storage_insert_ticket_attachments" on storage.objects;
drop policy if exists "storage_select_ticket_attachments" on storage.objects;

-- =========================================================
-- 3. HAPUS FILE STORAGE DAN BUCKET
-- =========================================================
-- Supabase tidak mengizinkan delete langsung dari storage.objects/storage.buckets.
-- Jadi bagian storage harus dibersihkan dari Dashboard:
--
-- Storage -> ticket-attachments -> hapus semua file/folder
-- lalu hapus bucket ticket-attachments.
--
-- Setelah itu schema.sql akan membuat bucket baru.

-- =========================================================
-- 4. HAPUS TABEL APLIKASI
-- =========================================================
-- Urutannya dari tabel anak ke tabel induk.
-- cascade dipakai supaya policy, constraint, dan relasi ikut bersih.

drop table if exists public.notifications cascade;
drop table if exists public.ticket_history cascade;
drop table if exists public.ticket_attachments cascade;
drop table if exists public.ticket_comments cascade;
drop table if exists public.tickets cascade;
drop table if exists public.profiles cascade;

-- =========================================================
-- 5. HAPUS FUNCTION APLIKASI
-- =========================================================

drop function if exists public.handle_new_user() cascade;
drop function if exists public.get_my_role() cascade;
drop function if exists public.notify_admins(uuid, text, uuid) cascade;
drop function if exists public.handle_ticket_status_change() cascade;
drop function if exists public.handle_ticket_update() cascade;
drop function if exists public.handle_ticket_created_notification() cascade;
drop function if exists public.handle_ticket_notification() cascade;
drop function if exists public.handle_comment_notification() cascade;

-- =========================================================
-- 6. HAPUS AKUN AUTH
-- =========================================================
-- Ini bagian yang membuat reset menjadi benar-benar bersih.
-- Setelah ini, semua akun lama harus register ulang dari aplikasi.
--
-- Kalau bagian ini error karena permission Supabase, hapus user lewat:
-- Dashboard Supabase -> Authentication -> Users -> delete user satu per satu.

delete from auth.identities;
delete from auth.sessions;
delete from auth.refresh_tokens;
delete from auth.users;

-- =========================================================
-- RESET SELESAI
-- =========================================================
-- Setelah file ini sukses, langsung jalankan supabase/schema.sql.
