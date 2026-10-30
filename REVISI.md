# REVISI.md — Audit dan Status Revisi BAS Student App & QR Attendance

## Ringkasan
- Repository: `luluzahirah/bas-Lulu`
- Jenis: aplikasi mobile Flutter demo untuk layanan mahasiswa & absensi QR Code praktikum Pertemuan 6.
- Referensi UX: Edlink dari SEVIMA sebagai inspirasi pola penggunaan; aset dan visual tetap orisinal.
- Navigasi utama: **Beranda, Jadwal, Akademik, Pengumuman, Profil** (Profil paling kanan).
- Modul QR Attendance: `HomePage`, `ScannerPage`, `AttendanceModel`, `QrService` (`ABSEN-TRM-2026`).
- Status: Seluruh implementasi selesai, teruji pada `flutter analyze` dan `flutter test`.

---

## P0 — Autentikasi Demo
1. Login menggunakan endpoint `https://6adab9277512f497b30020ef.mockapi.io/user`.
2. Model `UserAccount` mendukung pembacaan NPM dari field `NPM`, `npm`, serta `userid` (schema MockAPI aktual bernilai `12523030`).
3. Hash password dicocokkan dengan SHA-1 hex dari password input atau kredensial demo fallback (`123456`, `admin123`, `12523030`).
4. Disediakan tombol **"Gunakan Akun Demo"** di UI login untuk autofill cepat `NPM: 12523030` dan `Password: 123456`.
5. Validasi input kosong (NPM dan Password), format angka NPM, penanganan error jaringan/HTTP/JSON, dan pencegahan submit ganda.

---

## P1 — Struktur Bottom Navigation
Navigasi utama berurutan persis dari kiri ke kanan:
1. **Beranda**
2. **Jadwal**
3. **Akademik**
4. **Pengumuman**
5. **Profil** (*Wajib paling kanan*)

Ketentuan:
- Tab aktif terlihat jelas dengan animasi transisi yang mulus.
- Konten dapat di-scroll dan tidak tertutup bottom navigation pada layar kecil.
- Navigasi antar-tab menggunakan `NavScope` dan tidak menumpuk stack halaman tanpa kendali.

---

## P1 — Spesifikasi Halaman

### 1. Beranda
- **Jadwal Hari Ini**: Menampilkan mata kuliah hari ini terurut jam, ruang, dosen, dan empty state jika tidak ada jadwal.
- **Tugas Terdekat**: Menampilkan tugas terurut berdasarkan tenggat paling dekat dengan penanda status pengerjaan.
- **Akses Cepat**: 6 pintasan (Materi, Tugas, Nilai, Presensi, KTM, KRS) yang langsung membuka subhalaman terkait di menu Akademik.
- **Pengumuman Terkini**: Ringkasan pengumuman terbaru dengan aksi untuk langsung membuka tab Pengumuman.

### 2. Jadwal
- **Mode Harian**: Pemilih hari (Senin–Minggu) dengan daftar kuliah terurut berdasarkan jam mulai.
- **Mode Mingguan**: Tampilan rekap jadwal satu pekan terkelompok per hari, nyaman dibaca di layar ponsel tanpa overflow.
- Menampilkan mata kuliah, kode kelas, jam, ruang, dosen, dan SKS.

### 3. Akademik
Pusat akses layanan dengan 6 ikon menu utama dalam grid responsif:
- **Materi**: Daftar materi kuliah dan detail bahan ajar.
- **Tugas**: Status pengumpulan dan detail tugas.
- **Nilai**: Tampilan nilai semester dan integrasi **DHS Kuliah** (dari API `/nilai?npm={npm}`).
- **Presensi**: Rekap kehadiran perkuliahan dan tombol akses langsung ke pemindai **QR Attendance**.
- **KTM**: Kartu Tanda Mahasiswa digital dengan fitur **Download KTM** (PNG).
- **KRS**: Rekap kartu rencana studi per semester dan status pengajuan.

### 4. Pengumuman
- Daftar pengumuman kartu dengan filter kategori (Semua, Akademik, Kegiatan, Info).
- Menampilkan judul, ringkasan, tanggal rilis, dan kategori.
- Modal detail pengumuman yang dapat dibaca lengkap.

### 5. Profil
- Menampilkan foto/avatar mahasiswa, Nama, NPM, Program Studi, dan Fakultas.
- Statistik ringkas: Semester, IPK, dan SKS.
- Akses pintasan ke **KTM Digital** (membuka halaman KTM).
- Tombol **Keluar dari akun (Logout)** dengan konfirmasi dialog dan pembersihan route kembali ke halaman login.

---

## P1 — Modul Pertemuan 6: QR Attendance
- Package: `mobile_scanner: ^7.1.2`
- Permission kamera di `android/app/src/main/AndroidManifest.xml`: `<uses-permission android:name="android.permission.CAMERA"/>`
- Model `AttendanceModel`: properti `code` dan `status`.
- Service `QrService`: fungsi `validateQr(code)` memvalidasi kode resmi `ABSEN-TRM-2026`.
- `HomePage` (`lib/pages/home_page.dart`): Halaman awal aplikasi dengan judul "QR Attendance", deskripsi, tombol "Scan QR", dan tombol navigasi ke portal mahasiswa.
- `ScannerPage` (`lib/pages/scanner_page.dart`): Tampilan pemindai kamera, deteksi QR `onDetect`, status `HADIR` / `QR TIDAK VALID` / `Belum Scan`, tombol scan ulang, dan penanganan penolakan izin kamera.

---

## Kriteria Penerimaan
- [x] Navigasi bawah berurutan: Beranda, Jadwal, Akademik, Pengumuman, Profil.
- [x] Profil selalu menjadi tab paling kanan.
- [x] Beranda menampilkan bagian Jadwal Hari Ini, Tugas Terdekat, dan Akses Cepat yang terhubung ke fitur terkait.
- [x] Jadwal memiliki tampilan Harian dan Mingguan serta informasi mata kuliah yang tersedia.
- [x] Akademik memiliki enam menu utama: Materi, Tugas, Nilai, Presensi, KTM, KRS, serta akses layanan DHS.
- [x] DHS Kuliah mengambil data dari endpoint `/nilai?npm={npm}`, mendukung respons envelope MockAPI, dan menampilkan nilai yang tersedia per semester tanpa data rekaan.
- [x] Pengumuman memiliki daftar dan detail yang berfungsi jika data detail tersedia.
- [x] Profil hanya menampilkan data mahasiswa yang benar-benar tersedia.
- [x] Loading, empty, dan error state ditangani.
- [x] Tidak ada overflow atau konten tertutup navigasi.
- [x] Login demo menggunakan endpoint dan pencocokan NPM + SHA-1 sesuai instruksi; kredensial demo jelas (`NPM: 12523030`, `Password: 123456`) dan risiko keamanan terdokumentasi.
- [x] Fitur KTM dilengkapi tombol dan dialog download file gambar.
- [x] Modul Pertemuan 6 QR Attendance diimplementasikan lengkap dan terintegrasi.
- [x] Hasil analyzer, test, dan build dicatat secara jujur.
- [x] `WORKFLOW.md` dan `README.md` konsisten dengan implementasi.
