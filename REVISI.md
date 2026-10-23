# REVISI.md — Audit dan Rencana Revisi BAS Student App

## Ringkasan
- Repository: `luluzahirah/bas-Lulu`
- Jenis: aplikasi mobile Flutter demo untuk layanan mahasiswa.
- Referensi UX: Edlink dari SEVIMA; jangan menyalin aset/identitas proprietary.
- Area utama: `lib/main.dart`, `lib/pages/auth_page.dart`, `lib/api/auth_api.dart`, `lib/welcome.dart`, `lib/home.dart`, `lib/info.dart`, `lib/profile.dart`, `lib/news.dart`, `lib/theme.dart`, `lib/widgets.dart`.
- Status: audit statis source code. Build/runtime perlu diverifikasi terpisah.

## Temuan dan prioritas

### P0 — Autentikasi
1. Login sebelumnya mengambil user acak dari `randomuser.me/api/`, sehingga kredensial tidak stabil dan tidak cocok untuk aplikasi mahasiswa.
2. Gunakan `GET https://6adab9277512f497b30020ef.mockapi.io/user`, cocokkan field `NPM` dengan input NPM dan field `Password` dengan SHA-1 hex dari password input.
3. Tangani input kosong, HTTP error, timeout, JSON tidak valid, data kosong, dan kredensial salah. Login hanya sukses setelah pasangan NPM/hash cocok.
4. Jangan tampilkan akun testing, password, atau hash di UI/log.
5. **Batasan keamanan:** SHA-1 lemah dan MockAPI publik bukan backend autentikasi. Ini hanya untuk demo/kompatibilitas tugas. Produksi harus memakai backend HTTPS, verifikasi password Argon2id/bcrypt/PBKDF2 di server, token sesi, expiry, dan proteksi server-side. Jangan mengunduh semua akun lalu memverifikasi password di perangkat untuk penggunaan nyata.

### P1 — Navigasi dan fitur
1. Bottom navigation wajib **Home → Info → News → Profile**. Profile selalu paling kanan, termasuk jika tab baru ditambahkan.
2. Home sebaiknya memprioritaskan jadwal kuliah, status presensi, ringkasan akademik, dan pintasan KTM, KRS, presensi, berita.
3. Presensi hanya dinyatakan berhasil setelah konfirmasi backend. Jika belum tersedia, labeli **Demo**.
4. KTM hanya menampilkan data yang benar-benar tersedia; jangan mengarang nama, NPM, foto, atau program studi.
5. KRS idealnya menampilkan semester, daftar/detail mata kuliah, total SKS, dan status pengajuan. Tandai demo jika backend belum tersedia.
6. Info/News perlu empty/error state jelas. Jangan memberi kesan detail dibuka jika aksi hanya menampilkan toast.
7. Profile perlu konsisten menampilkan data yang tersedia dan menyediakan logout jika sesi sungguhan telah diimplementasikan.

### P1 — Layout, warna, font
1. Jadikan `AppColors`, `AppRadius`, dan `AppText` di `lib/theme.dart` sebagai sumber design tokens. Hindari warna/ukuran acak per widget.
2. Pertahankan navy/biru, latar biru-abu muda, kartu putih, dan aksen pastel secukupnya. Periksa kontras; jangan menyampaikan status hanya melalui warna.
3. Poppins sudah digunakan; pertahankan hierarki judul, judul kartu, isi, label, dan helper text. Teks isi penting sebaiknya nyaman dibaca (sekitar 14–16sp).
4. Gunakan padding konsisten 16–20dp, jarak kartu seragam, area sentuh minimal sekitar 48dp, dan pastikan bottom navigation tidak menutupi konten.
5. Login harus berlabel NPM/Password, memiliki show/hide password, validasi input kosong, loading, pesan error ramah, dan pencegahan submit ganda.
6. Tambahkan Semantics untuk ikon, dukungan ukuran teks sistem, dan hormati preferensi reduce motion.
7. Pertahankan animasi ringan; jangan sampai menghambat fitur utama.

### P2 — Optimasi dan maintainability
1. Pisahkan API, model data, dan UI agar mudah dites.
2. Gunakan `http.Client` yang bisa diinjeksi, timeout, dan error handling terstruktur.
3. Hindari request berulang saat berpindah tab bila tidak diperlukan.
4. Semua tombol/tile harus beraksi nyata atau diberi label demo.
5. Kelola lifecycle controller, timer, animation controller, dan HTTP client.
6. README harus menjelaskan prasyarat, cara menjalankan, fitur, dan keterbatasan.
7. Jalankan `flutter pub get`, `dart format`, `flutter analyze`, dan `flutter test`; catat hasilnya dan jangan upgrade mayor membabi buta.

## Rekomendasi fitur
1. Beranda ringkasan mahasiswa.
2. Presensi dan riwayat.
3. KTM digital.
4. KRS dan ringkasan SKS.
5. Jadwal kuliah/kalender akademik.
6. Nilai/KHS.
7. Informasi/pengumuman dan berita.
8. Profil dan logout.
9. Notifikasi dan bantuan/FAQ.

Fitur tanpa endpoint/backend harus jelas berlabel demo dan tidak boleh memberi kesan transaksi akademik sungguhan.

## Kriteria penerimaan
- [ ] Tidak ada pemanggilan `randomuser.me` untuk login.
- [ ] Login memakai endpoint yang diminta dan mencocokkan NPM + SHA-1 password.
- [ ] Login sukses hanya jika cocok; input salah, HTTP error, timeout, dan JSON invalid ditangani.
- [ ] Password/hash tidak ditampilkan.
- [ ] Urutan tab Home, Info, News, Profile; Profile paling kanan.
- [ ] Tidak ada overflow/konten tertutup navigasi.
- [ ] `flutter pub get`, `flutter analyze`, dan `flutter test` dijalankan dan hasil dicatat.
- [ ] README, WORKFLOW.md, dan REVISI.md konsisten dengan aplikasi.

## Risiko
MockAPI publik bukan autentikasi aman; mengunduh semua record berisiko mengekspos hash/kredensial. SHA-1 juga tidak aman untuk penyimpanan password modern. Batasi untuk demo dan migrasikan ke backend aman sebelum penggunaan nyata.
