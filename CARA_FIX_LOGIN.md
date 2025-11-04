# Cara Fix Login "Email atau Password Salah"

## Masalah
- Data sudah masuk ke `user_profiles` ✅
- Tapi tidak bisa login dengan error "Email atau password salah" ❌

## Kemungkinan Penyebab

### 1. Email Confirmation Masih Aktif
Ini adalah penyebab paling umum. Supabase default memerlukan konfirmasi email sebelum bisa login.

**Solusi:**
1. Buka Supabase Dashboard
2. Klik **Authentication** → **Settings** (atau **Configuration**)
3. Scroll ke bagian **Email Auth**
4. Cari **"Enable email confirmations"** atau **"Confirm email"**
5. **Matikan/Uncheck** setting tersebut
6. Klik **Save**

Lihat detail di `DISABLE_EMAIL_CONFIRMATION.md`

### 2. Password Tidak Sesuai
- Pastikan password yang di-input sama dengan saat registrasi
- Cek apakah ada spasi di awal/akhir
- Cek case sensitivity (huruf besar/kecil)

**Solusi:**
- Coba reset password di Supabase Dashboard → Authentication → Users → Pilih user → Reset password
- Atau registrasi user baru dengan password yang jelas

### 3. Email Salah
- Pastikan email yang di-input sama persis dengan saat registrasi
- Cek apakah ada typo

## Cara Cek dan Fix di Supabase

### Cek Status User
1. Buka Supabase Dashboard
2. Klik **Authentication** → **Users**
3. Cari user dengan email yang bermasalah
4. Lihat kolom **Last sign in at**
   - Jika "Waiting for verification" → Email confirmation masih aktif
   - Jika ada tanggal → User sudah pernah login

### Confirm Email Manual (Jika Email Confirmation Aktif)
1. Di Authentication → Users
2. Klik user yang bermasalah
3. Scroll ke bagian **User Metadata**
4. Cari **email_confirmed** atau **confirmed_at**
5. Set ke `true` atau isi dengan timestamp sekarang

**Atau jalankan SQL ini:**
```sql
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email = 'email_user@example.com';
```

### Reset Password (Jika Lupa Password)
1. Di Authentication → Users
2. Klik user yang bermasalah
3. Klik **Reset Password**
4. Atau gunakan fitur "Forgot Password" di aplikasi (jika ada)

## Test Login Setelah Fix

1. **Restart aplikasi**: `flutter run`
2. **Coba login** dengan email dan password yang benar
3. **Cek console log** untuk error detail (jika masih gagal)

## Error Messages yang Mungkin Muncul

Setelah update code, aplikasi akan menampilkan error message yang lebih jelas:

- **"Email belum dikonfirmasi"** → Disable email confirmation
- **"Email atau password salah"** → Cek email/password
- **"Email tidak terdaftar"** → Registrasi dulu

## Quick Checklist

- [ ] Email confirmation sudah di-disable
- [ ] Email yang di-input benar (sama dengan saat registrasi)
- [ ] Password yang di-input benar
- [ ] User sudah ada di Authentication → Users
- [ ] Profil sudah ada di Table Editor → user_profiles
- [ ] Aplikasi sudah di-restart

## Jika Masih Gagal

1. **Cek console log** aplikasi untuk error detail
2. **Cek Supabase Logs** → **Postgres Logs** atau **Auth Logs**
3. **Coba registrasi user baru** untuk test apakah registrasi masih bekerja
4. **Cek apakah email confirmation benar-benar sudah di-disable**

## Catatan Penting

⚠️ **Untuk Development:**
- Disable email confirmation lebih praktis
- Tapi untuk production, lebih baik aktifkan untuk keamanan

⚠️ **Password:**
- Supabase menyimpan password dalam bentuk hash
- Tidak bisa melihat password asli di dashboard
- Harus reset password jika lupa

