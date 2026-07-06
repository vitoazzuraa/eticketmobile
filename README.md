# E-Ticket Helpdesk

Aplikasi mobile helpdesk berbasis Flutter dan Supabase. Aplikasi ini dipakai untuk membuat tiket kendala, menugaskan helpdesk, memberi komentar, melihat riwayat status, dan menerima notifikasi.

## Teknologi

- Flutter
- Dart
- Supabase Auth
- Supabase PostgreSQL
- Supabase Row Level Security
- Supabase Storage

## Dependensi Flutter

- `supabase_flutter`
- `flutter_riverpod`
- `image_picker`
- `google_fonts`
- `iconsax_flutter`
- `cupertino_icons`

## Role Pengguna

- `user`: membuat tiket, melihat tiket miliknya, memberi komentar, dan melihat notifikasi.
- `helpdesk`: melihat tiket yang ditugaskan, mengubah status tiket, memberi komentar, dan melihat notifikasi.
- `admin`: melihat semua tiket, mengelola user, menugaskan helpdesk, mengubah status tiket, dan melihat notifikasi.

## Struktur Penting

- `lib/models`: model data aplikasi.
- `lib/services`: komunikasi Flutter dengan Supabase.
- `lib/providers`: state management Riverpod.
- `lib/screens`: tampilan aplikasi.
- `supabase/schema.sql`: schema database, RLS policy, trigger, function, dan storage bucket.
- `supabase/reset_full.sql`: reset database Supabase jika ingin mulai ulang.

## Cara Menjalankan

1. Jalankan `flutter pub get`.
2. Buat project Supabase.
3. Jalankan isi file `supabase/schema.sql` di Supabase SQL Editor.
4. Sesuaikan URL dan anon key Supabase di `lib/core/supabase_client.dart`.
5. Jalankan aplikasi dengan `flutter run`.

## Build APK

```bash
flutter build apk --release
```

Hasil APK ada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

File APK untuk pengumpulan disimpan di `release/app-release.apk`.

## Catatan Keamanan

- Jangan commit `service_role key`, password database, file `.env`, atau keystore Android.
- Supabase `anon key` boleh dipakai di aplikasi client, tetapi keamanan data tetap harus dijaga dengan RLS policy.
- File APK sebaiknya dikumpulkan terpisah, bukan dimasukkan ke repository source code.
