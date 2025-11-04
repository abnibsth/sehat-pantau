# Panduan Cek dan Perbaiki Registrasi

## Masalah: Data tidak masuk ke Supabase setelah registrasi

### Langkah 1: Pastikan Migration SQL Sudah Dijalankan

1. Buka Supabase Dashboard: https://app.supabase.com
2. Pilih project Anda
3. Klik **SQL Editor** di sidebar kiri
4. Klik **New Query**
5. Copy **SEMUA** isi dari file `supabase_migration.sql` di project Anda
6. Paste ke SQL Editor
7. Klik **Run** (atau tekan Ctrl+Enter)
8. Pastikan tidak ada error (harus muncul "Success" atau "0 errors")

### Langkah 2: Verifikasi Tabel Sudah Dibuat

1. Di Supabase Dashboard, klik **Table Editor**
2. Pastikan tabel `user_profiles` ada di daftar
3. Jika tidak ada, kembali ke Langkah 1 dan jalankan migration lagi

### Langkah 3: Cek RLS Policies

1. Di Table Editor, klik tabel `user_profiles`
2. Lihat di bagian atas, harus ada "RLS enabled" (Row Level Security)
3. Klik **3 RLS policies** untuk melihat policies
4. Pastikan ada policy yang mengizinkan INSERT untuk user sendiri

Jika policies tidak ada, jalankan SQL ini di SQL Editor:

```sql
-- Pastikan RLS enabled
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy untuk INSERT (user bisa insert profil mereka sendiri)
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy untuk SELECT (user bisa lihat profil mereka sendiri)
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

-- Policy untuk UPDATE (user bisa update profil mereka sendiri)
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);
```

### Langkah 4: Test Registrasi

1. Jalankan aplikasi: `flutter run`
2. Coba registrasi dengan email baru
3. Lihat console log untuk melihat error (jika ada)
4. Setelah registrasi berhasil, cek di Supabase Dashboard:
   - Table Editor → `user_profiles` → harus ada data baru
   - Authentication → Users → harus ada user baru

### Langkah 5: Cek Error di Console

Jika masih tidak berhasil, lihat error di console aplikasi. Error yang mungkin muncul:

1. **"relation does not exist"** → Migration belum dijalankan
2. **"new row violates row-level security policy"** → RLS policy belum dibuat
3. **"duplicate key value"** → User sudah terdaftar sebelumnya

### Troubleshooting Tambahan

#### Jika user sudah terdaftar tapi profil tidak ada:

Jalankan SQL ini untuk membuat profil manual (ganti USER_ID dengan ID user dari Authentication):

```sql
INSERT INTO user_profiles (id, name, preferences, created_at)
VALUES (
  'USER_ID_DISINI',
  'Nama User',
  '{}',
  NOW()
)
ON CONFLICT (id) DO NOTHING;
```

#### Jika masih error setelah semua langkah:

1. Cek apakah Supabase URL dan API Key sudah benar di `lib/main.dart`
2. Pastikan koneksi internet stabil
3. Restart aplikasi
4. Cek logs di Supabase Dashboard → Logs → untuk melihat error dari server

## Checklist

- [ ] Migration SQL sudah dijalankan
- [ ] Tabel `user_profiles` sudah ada
- [ ] RLS policies sudah dibuat
- [ ] URL dan API Key sudah benar di `lib/main.dart`
- [ ] Aplikasi sudah di-restart setelah perubahan

