# Cara Disable Email Confirmation di Supabase

## Masalah
Error "Email not confirmed" muncul karena Supabase default memerlukan konfirmasi email sebelum user bisa login.

## Solusi: Disable Email Confirmation

### Langkah 1: Buka Authentication Settings
1. Buka Supabase Dashboard: https://app.supabase.com
2. Pilih project Anda
3. Klik **Authentication** di sidebar kiri
4. Klik **Settings** (atau **Configuration**)

### Langkah 2: Disable Email Confirmation
1. Scroll ke bagian **Email Auth**
2. Cari setting **"Enable email confirmations"** atau **"Confirm email"**
3. **Matikan/Uncheck** setting tersebut
4. Klik **Save**

### Alternatif: Untuk Development
Jika Anda hanya ingin disable untuk development/testing:
1. Di Authentication Settings, cari **"SMTP Settings"** atau **"Email Templates"**
2. Untuk development, Anda bisa menggunakan **"Development Mode"** yang auto-confirm semua email

### Setelah Disable
- User bisa langsung login setelah registrasi tanpa perlu konfirmasi email
- Cocok untuk aplikasi yang tidak memerlukan verifikasi email

## Catatan
⚠️ **Production**: Jika aplikasi untuk production, lebih baik tetap aktifkan email confirmation untuk keamanan. Tapi untuk testing/development, disable lebih praktis.

