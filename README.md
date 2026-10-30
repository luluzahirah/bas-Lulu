# BAS Student App & QR Attendance

Aplikasi mobile Flutter demo layanan mahasiswa dengan dua modul terintegrasi:
1. **QR Attendance (Praktikum Pertemuan 6)**: Sistem absensi mahasiswa berbasis pemindaian QR Code menggunakan kamera smartphone.
2. **BAS Student App (Portal Mahasiswa)**: Navigasi lengkap mahasiswa dengan 5 menu utama: **Beranda, Jadwal, Akademik, Pengumuman, Profil**.

---

## 🚀 Cara Menjalankan Aplikasi

Pastikan Flutter SDK (>= 3.12.2) sudah terpasang di sistem.

```bash
# 1. Unduh dependencies
flutter pub get

# 2. Jalankan aplikasi
flutter run
```

### Build APK Debug
```bash
flutter build apk --debug
```
Output APK tersimpan di: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 🔑 Kredensial Login Demo (BAS Student App)

Halaman login menggunakan endpoint demo MockAPI: `https://6adab9277512f497b30020ef.mockapi.io/user`.

| Field | Nilai Demo |
|---|---|
| **NPM** | `12523030` |
| **Password** | `123456` (atau `admin`, `testpass`, `12523030`) |
| **Nama Akun** | Sofi Putri Rahayu |

> **Fitur Praktis**: Pada halaman login, tersedia tombol **"Gunakan Akun Demo"** untuk mengisi NPM dan Password secara otomatis dalam satu klik tanpa perlu mengetik manual.

---

## 📱 Fitur & Navigasi

### A. QR Code Attendance (Modul Pertemuan 6)
Aplikasi awal langsung membuka halaman `HomePage` QR Attendance sesuai panduan modul praktikum:
- **`lib/models/attendance_model.dart`**: Model data presensi dengan atribut `code` dan `status`.
- **`lib/services/qr_service.dart`**: Validasi QR Code lokal melalui fungsi `validateQr(code)`:
  - Kode valid: **`ABSEN-TRM-2026`** -> Status **`HADIR`** (hijau).
  - Kode tidak valid -> Status **`QR TIDAK VALID`** (merah).
  - Sebelum scan -> Status **`Belum Scan`**.
- **`lib/pages/home_page.dart`**: Menampilkan judul "QR Attendance", deskripsi presensi QR, tombol "Scan QR", serta pintasan membuka BAS Student App.
- **`lib/pages/scanner_page.dart`**: Kamera pemindai QR berbasis package `mobile_scanner: ^7.1.2`, penanganan izin kamera (`<uses-permission android:name="android.permission.CAMERA"/>`), pencegahan pemrosesan ganda, overlay panduan bidik, tombol scan ulang, senter (torch), dan pergantian kamera.
- Terintegrasi juga di menu **Akademik > Presensi** pada portal mahasiswa.

### B. BAS Student App (5 Menu Navigasi Bawah)
Urutan bottom navigation dari kiri ke kanan:
1. **Beranda**: Dashboard utama berisi *Jadwal Hari Ini* (terurut jam), *Tugas Terdekat* (terurut tenggat), dan *Akses Cepat* ke seluruh layanan akademik.
2. **Jadwal**: Mode **Harian** (pilih hari/tanggal) dan mode **Mingguan** (tampilan per hari sepekan) yang nyaman di layar ponsel.
3. **Akademik**: Grid responsif 6 menu utama:
   - **Materi**: Materi perkuliahan terstruktur.
   - **Tugas**: Status pengerjaan dan pengumpulan tugas.
   - **Nilai**: Ringkasan nilai dan akses detail **DHS Kuliah** (dari API `/nilai?npm={npm}`).
   - **Presensi**: Rekap kehadiran dan tombol akses **Scan QR Presensi**.
   - **KTM**: Kartu Tanda Mahasiswa digital dengan fitur **Download KTM** (PNG).
   - **KRS**: Rencana studi dan status pengajuan semester.
4. **Pengumuman**: Daftar berita dan pengumuman kampus dengan filter kategori dan tampilan detail.
5. **Profil** (*Wajib paling kanan*): Identitas resmi mahasiswa dari data yang tersedia, statistik semester/IPK/SKS, akses pintasan ke KTM Digital, dan tombol konfirmasi Logout.

---

## 🧪 Pengujian Aplikasi

### Menjalankan Seluruh Automated Test
```bash
flutter test
```
Hasil uji mencakup:
- Validasi kode valid `ABSEN-TRM-2026` -> `HADIR`.
- Validasi kode selain itu -> `QR TIDAK VALID`.
- Uji model data `AttendanceModel`.
- Uji parsing schema `UserAccount` (termasuk `userid` sebagai NPM).
- Uji widget flow login demo membuka `WelcomeScreen`.
- Uji widget `HomePage` menampilkan judul dan tombol scan.

### Menjalankan Static Code Analysis
```bash
flutter analyze
```

---

## ⚠️ Batasan dan Catatan Keamanan
- Endpoint MockAPI dan hashing SHA-1 di sisi client digunakan khusus untuk tujuan demo dan praktikum kuliah. Untuk tahap produksi, autentikasi wajib menerapkan backend HTTPS resmi, algoritma password modern di server (seperti Argon2id/bcrypt), serta manajemen sesi bertoken JWT.
