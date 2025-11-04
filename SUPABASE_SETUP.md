# Setup Supabase untuk Aplikasi Sehat dan Pantau

## Langkah-langkah Setup

### 1. Buat Akun Supabase
1. Kunjungi https://supabase.com
2. Daftar atau login ke akun Anda
3. Buat project baru

### 2. Dapatkan API Keys
1. Di dashboard Supabase, klik **Settings** (ikon gear)
2. Pilih **API**
3. Copy **URL** dan **anon/public key**
4. Paste ke file `lib/main.dart`:
   ```dart
   const String supabaseUrl = 'PASTE_URL_DISINI';
   const String supabaseAnonKey = 'PASTE_ANON_KEY_DISINI';
   ```

### 3. Setup Database
1. Di dashboard Supabase, klik **SQL Editor**
2. Buka file `supabase_migration.sql` di project Anda
3. Copy semua isi file tersebut
4. Paste ke SQL Editor di Supabase
5. Klik **Run** untuk menjalankan migration
6. Pastikan semua tabel berhasil dibuat

### 4. Install Dependencies
Jalankan di terminal:
```bash
flutter pub get
```

### 5. Test Koneksi
1. Jalankan aplikasi
2. Coba register user baru
3. Data seharusnya tersimpan di Supabase

## Tabel yang Dibuat

Migration akan membuat tabel-tabel berikut:
- `user_profiles` - Profil user tambahan
- `food_data` - Data makanan yang dikonsumsi
- `sleep_data` - Data tidur harian
- `step_data` - Data langkah harian
- `mood_entries` - Entri mood pengguna
- `smart_reminders` - Reminder pintar
- `reminder_settings` - Pengaturan reminder
- `user_badges` - Badge yang dimiliki user
- `user_achievements` - Achievement yang dicapai user

## Security (Row Level Security)

Semua tabel sudah dilengkapi dengan Row Level Security (RLS) yang memastikan:
- User hanya bisa melihat dan mengubah data mereka sendiri
- Data antar user terisolasi dengan baik

## Troubleshooting

### Error: "Invalid API key"
- Pastikan URL dan anon key sudah benar di `lib/main.dart`
- Pastikan tidak ada spasi atau karakter tambahan

### Error: "relation does not exist"
- Pastikan migration SQL sudah dijalankan
- Cek di Supabase dashboard > Table Editor apakah tabel sudah ada

### Data tidak tersimpan
- Cek koneksi internet
- Cek apakah user sudah login
- Lihat log error di console aplikasi

## Catatan Penting

⚠️ **JANGAN commit API keys ke Git!**
- Simpan URL dan key di file terpisah
- Atau gunakan environment variables
- File `lib/main.dart` sudah ada di `.gitignore` untuk mencegah commit tidak sengaja

