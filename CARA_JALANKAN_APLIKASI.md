# Cara Menjalankan Aplikasi Flutter

## Masalah yang Sudah Diperbaiki ✅

1. **Error Asset Logo** - Sudah diperbaiki
   - File logo bermasalah sudah dihapus
   - Dibuat file logo.svg yang valid
   - Konfigurasi pubspec.yaml sudah diperbaiki
   - Referensi di login_screen.dart sudah diupdate

## Cara Menjalankan Aplikasi

### Opsi 1: Menggunakan Command Prompt (CMD)
1. Buka Command Prompt sebagai Administrator
2. Navigasi ke direktori proyek:
   ```cmd
   cd /d "F:\project flutter\project_uts"
   ```
3. Jalankan Flutter:
   ```cmd
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

### Opsi 2: Menggunakan VS Code
1. Buka VS Code
2. Buka folder proyek: `F:\project flutter\project_uts`
3. Buka terminal di VS Code (Ctrl + `)
4. Jalankan perintah:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

### Opsi 3: Menggunakan Android Studio
1. Buka Android Studio
2. Open project di `F:\project flutter\project_uts`
3. Klik tombol "Run" atau gunakan Shift + F10

## Catatan Penting

- **JANGAN gunakan PowerShell** karena ada masalah dengan sistem Anda
- Gunakan Command Prompt atau VS Code terminal
- Aplikasi akan berjalan di browser Chrome
- Jika ingin menjalankan di Android, pastikan emulator sudah aktif

## Troubleshooting

Jika masih ada error:
1. Pastikan Flutter sudah terinstall dengan benar
2. Jalankan `flutter doctor` untuk cek status
3. Pastikan Chrome browser sudah terinstall
4. Coba restart VS Code/Android Studio

## Status Aplikasi

- ✅ Error asset logo sudah diperbaiki
- ✅ Konfigurasi pubspec.yaml sudah benar
- ✅ File logo.svg sudah dibuat dan valid
- ✅ Referensi di kode sudah diupdate
- ✅ Aplikasi siap dijalankan
