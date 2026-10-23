# REVISI.md — Audit dan Rencana Revisi BAS Student App

## Ringkasan
- Repository: `luluzahirah/bas-Lulu`
- Jenis: aplikasi mobile Flutter demo untuk layanan mahasiswa.
- Referensi UX: Edlink dari SEVIMA sebagai inspirasi pola penggunaan; jangan menyalin aset atau identitas proprietary.
- Tujuan revisi: menyusun navigasi utama mahasiswa menjadi **Beranda, Jadwal, Akademik, Pengumuman, Profil**.
- Area source code yang perlu diaudit: `lib/main.dart`, halaman navigasi, halaman login/API, serta widget dan tema yang digunakan. Sesuaikan path dengan struktur aktual repository.
- Status: dokumen rencana revisi; seluruh implementasi dan build harus diverifikasi di source code.

## P0 — Autentikasi demo
1. Login menggunakan endpoint `https://6adab9277512f497b30020ef.mockapi.io/user`.
2. Cocokkan field `NPM` dengan NPM yang dimasukkan dan field `Password` dengan SHA-1 hex dari password input, sesuai kontrak data demo.
3. Tangani input kosong, HTTP error, timeout, JSON tidak valid, data kosong, dan kredensial salah. Login hanya sukses setelah NPM dan hash cocok.
4. Jangan menampilkan password atau hash di UI/log.
5. **Batasan keamanan:** SHA-1 lemah dan MockAPI publik bukan backend autentikasi. Ini hanya untuk demo/kompatibilitas tugas. Produksi perlu backend HTTPS, hashing password modern di server (misalnya Argon2id/bcrypt/PBKDF2), sesi/token dengan expiry, dan otorisasi server-side. Jangan mengunduh seluruh akun lalu memverifikasi password di perangkat untuk penggunaan nyata.

## P1 — Struktur bottom navigation
Navigasi utama harus berurutan persis seperti berikut, dari kiri ke kanan:

1. **Beranda**
2. **Jadwal**
3. **Akademik**
4. **Pengumuman**
5. **Profil**

Ketentuan:
- Gunakan label dan ikon yang konsisten di seluruh aplikasi.
- **Profil wajib menjadi tab paling kanan.**
- Setiap tab harus membuka halaman yang sesuai; jangan membuat tombol yang hanya dekoratif.
- Pertahankan tab aktif saat berpindah halaman dan hindari halaman bertumpuk tanpa kendali.
- Pastikan konten dapat di-scroll dan tidak tertutup bottom navigation, termasuk pada layar kecil.
- Jika fitur masih menggunakan data contoh atau belum terhubung backend, tampilkan penanda **Demo** atau empty state yang jelas.

## P1 — Spesifikasi halaman

<<<<<<< HEAD
=======
### DHS Kuliah
Menu **Akademik > DHS > DHS Kuliah** menampilkan nilai per mata kuliah yang
tersedia dari endpoint demo
`https://6adab9277512f497b30020ef.mockapi.io/nilai?npm={npm}`. Kelompokkan
baris nilai menurut semester/tahun akademik dan tampilkan kode mata kuliah,
nilai, huruf mutu, serta angka mutu yang memang tersedia. Jangan mengarang
nama mata kuliah, SKS, IPK, atau nilai yang tidak ada pada respons.

Endpoint nilai tersebut berbeda dari endpoint login `/user`; data nilainya
tidak dapat digunakan untuk autentikasi.

>>>>>>> f8fc6fe (Revisi)
### 1. Beranda
Beranda menjadi dashboard ringkas untuk kebutuhan mahasiswa sehari-hari. Prioritaskan:
- **Jadwal Hari Ini:** daftar mata kuliah hari ini, jam, ruang, dan dosen jika datanya tersedia.
- **Tugas Terdekat:** daftar tugas dengan mata kuliah dan tenggat; tampilkan penanda tenggat yang dekat.
- **Akses Cepat:** ikon/tile yang terhubung ke halaman Akademik seperti Materi, Tugas, Nilai, Presensi, KTM, dan KRS.
- Boleh menampilkan ringkasan pengumuman terbaru bila tersedia, dengan aksi untuk membuka halaman Pengumuman.
- Bila data belum tersedia, tampilkan empty state yang informatif; jangan membuat jadwal atau tugas palsu seolah data asli.

### 2. Jadwal
Sediakan pilihan tampilan **Harian** dan **Mingguan**:
- Tampilan Harian: pilih tanggal/hari dan tampilkan mata kuliah secara berurutan menurut jam.
- Tampilan Mingguan: tampilkan jadwal per hari dalam minggu yang dipilih.
- Informasi setiap jadwal dapat mencakup nama mata kuliah, kode/kelas, jam mulai–selesai, ruang, dan dosen, hanya jika tersedia dari data.
- Berikan state untuk loading, jadwal kosong, dan kegagalan memuat data.
- Perhatikan layar ponsel: hindari tabel terlalu lebar; gunakan kartu atau daftar yang mudah dibaca.

### 3. Akademik
Halaman Akademik menjadi pusat akses fitur akademik. Tampilkan enam ikon/menu terpisah:
- **Materi:** daftar materi per mata kuliah dan detail/tautan materi jika tersedia.
- **Tugas:** daftar tugas, mata kuliah, tenggat, dan status pengerjaan/pengumpulan jika didukung.
- **Nilai:** nilai per mata kuliah/semester jika tersedia.
- **Presensi:** ringkasan kehadiran dan riwayat; jangan menyatakan presensi berhasil tanpa konfirmasi backend.
- **KTM:** kartu mahasiswa digital dari data yang benar-benar tersedia.
- **KRS:** daftar mata kuliah per semester, total SKS, dan status pengajuan jika tersedia.

Setiap ikon membuka halaman atau sub-menu sendiri. Beri label teks di bawah ikon, area sentuh yang memadai, dan layout grid yang responsif. Jangan mengarang nilai, identitas, status presensi, atau transaksi KRS. Jika backend belum ada, tandai fitur sebagai demo.

### 4. Pengumuman
Buat halaman pengumuman bergaya aplikasi layanan akademik seperti Edlink, dengan desain orisinal:
- Daftar pengumuman dalam kartu/list yang mudah dipindai.
- Setiap item menampilkan judul, ringkasan, tanggal, dan kategori/sumber jika tersedia.
- Item dapat dibuka ke halaman detail bila detail tersedia.
- Sediakan penanda pengumuman baru/belum dibaca hanya jika status tersebut benar-benar dikelola.
- Tampilkan loading, empty state, dan error state. Jangan mengarang pengumuman resmi kampus atau menampilkan tombol yang tidak berfungsi.

### 5. Profil
Halaman Profil berisi informasi mahasiswa yang tersedia:
- Foto/avatar jika tersedia.
- Nama, NPM, program studi, fakultas, dan informasi lain hanya jika bersumber dari data.
- Akses ke KTM dapat diarahkan ke menu Akademik > KTM.
- Tombol logout jika sesi autentikasi telah diimplementasikan; saat logout, hapus sesi lokal yang relevan dan kembali ke login.
- Jangan menampilkan placeholder seolah data pribadi asli.

## P1 — UI/UX dan aksesibilitas
1. Jadikan design tokens di file tema yang sudah ada sebagai sumber warna, radius, dan tipografi; jangan menduplikasi nilai secara acak.
2. Pertahankan tampilan kampus yang bersih: navy/biru, latar biru-abu muda, kartu putih, dan aksen secukupnya. Periksa kontras warna.
3. Gunakan hierarki teks konsisten; teks isi penting umumnya nyaman pada ukuran sekitar 14–16sp.
4. Gunakan padding konsisten sekitar 16–20dp dan area sentuh minimal sekitar 48dp.
5. Ikon bottom navigation dan menu Akademik harus memiliki label teks serta Semantics yang sesuai.
6. Sediakan state loading, success, empty, dan error yang jelas.
7. Pastikan layout responsif, tidak overflow, dan mendukung ukuran teks sistem.
8. Animasi ringan boleh digunakan selama tidak menghambat tugas utama.

## P2 — Struktur kode, optimasi, dan pengujian
1. Pisahkan UI, model data, dan layanan API sesuai pola proyek yang sudah digunakan.
2. Hindari request berulang ketika berpindah tab bila tidak diperlukan.
3. Kelola lifecycle controller, timer, animation controller, dan HTTP client.
4. Semua tombol/tile harus berfungsi atau diberi penanda demo.
5. Jangan menambahkan dependensi besar tanpa kebutuhan yang jelas.
6. Perbarui README agar menjelaskan prasyarat, cara menjalankan, fitur, dan keterbatasan.
7. Jalankan `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, dan `flutter build apk --debug` jika environment mendukung. Catat hasil sebenarnya; jangan mengklaim pengujian lulus bila belum dijalankan.

## Kriteria penerimaan
- [ ] Navigasi bawah berurutan: Beranda, Jadwal, Akademik, Pengumuman, Profil.
- [ ] Profil selalu menjadi tab paling kanan.
- [ ] Beranda menampilkan bagian Jadwal Hari Ini, Tugas Terdekat, dan Akses Cepat yang terhubung ke fitur terkait.
- [ ] Jadwal memiliki tampilan Harian dan Mingguan serta informasi mata kuliah yang tersedia.
<<<<<<< HEAD
- [ ] Akademik memiliki enam menu terpisah: Materi, Tugas, Nilai, Presensi, KTM, KRS.
=======
- [x] Akademik memiliki enam menu utama: Materi, Tugas, Nilai, Presensi, KTM, KRS, serta akses layanan DHS.
- [x] DHS Kuliah mengambil data dari endpoint `/nilai?npm={npm}`, mendukung respons envelope MockAPI, dan menampilkan nilai yang tersedia per semester tanpa data rekaan.
>>>>>>> f8fc6fe (Revisi)
- [ ] Pengumuman memiliki daftar dan detail yang berfungsi jika data detail tersedia.
- [ ] Profil hanya menampilkan data mahasiswa yang benar-benar tersedia.
- [ ] Loading, empty, dan error state ditangani.
- [ ] Tidak ada overflow atau konten tertutup navigasi.
- [ ] Login demo menggunakan endpoint dan pencocokan NPM + SHA-1 sesuai instruksi; risiko keamanan terdokumentasi.
- [ ] Hasil analyzer, test, dan build dicatat secara jujur.
- [ ] `WORKFLOW.md` dan README konsisten dengan implementasi.

## Risiko dan catatan
MockAPI publik bukan autentikasi aman; SHA-1 tidak layak untuk penyimpanan password modern. Fitur akademik yang belum terhubung ke backend harus ditandai sebagai demo dan tidak boleh memberi kesan bahwa data, presensi, nilai, atau pengajuan KRS telah tersimpan secara resmi.
