# Langkah Perbaikan: User Sudah Terdaftar Tapi Profil Kosong

## Masalah
- User sudah terdaftar di Authentication Users ✅
- Tapi profil tidak ada di `user_profiles` ❌
- Tidak bisa login karena aplikasi cek `user_profiles`

## Solusi Cepat

### Langkah 1: Buat Profil untuk User yang Sudah Ada

1. Buka Supabase Dashboard
2. Klik **SQL Editor**
3. Copy **SEMUA** isi dari file `fix_existing_users.sql`
4. Paste dan klik **Run**
5. Ini akan membuat profil untuk semua user yang belum punya profil

### Langkah 2: Verifikasi Profil Sudah Dibuat

1. Buka **Table Editor**
2. Klik tabel `user_profiles`
3. Harus ada data user yang sudah terdaftar

### Langkah 3: Pastikan Trigger Sudah Aktif

Trigger akan otomatis membuat profil untuk user baru yang registrasi. Pastikan sudah dijalankan dari `fix_existing_users.sql`.

### Langkah 4: Test Login

1. Restart aplikasi: `flutter run`
2. Coba login dengan email yang sudah terdaftar
3. Harusnya bisa login sekarang

## Jika Masih Error

### Cek RLS Policies
1. Buka **Table Editor** → `user_profiles`
2. Klik **3 RLS policies**
3. Pastikan ada 3 policies:
   - Users can insert own profile (INSERT)
   - Users can view own profile (SELECT)
   - Users can update own profile (UPDATE)

Jika tidak ada, jalankan lagi `fix_existing_users.sql`

### Cek Logs di Supabase
1. Buka **Logs** → **Postgres Logs**
2. Lihat apakah ada error saat insert profil

## Troubleshooting

**Q: Profil masih kosong setelah jalankan SQL?**
- Pastikan SQL berhasil dijalankan (cek output)
- Pastikan user ID benar
- Cek apakah ada constraint violation

**Q: Masih tidak bisa login?**
- Cek console log aplikasi untuk error detail
- Pastikan email confirmation sudah di-disable
- Restart aplikasi

## Catatan Penting

⚠️ **Setelah perbaikan ini:**
- User yang sudah terdaftar akan punya profil
- User baru yang registrasi akan otomatis dapat profil (via trigger)
- Semua data akan tersinkronisasi

