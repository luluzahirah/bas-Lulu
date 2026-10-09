# Design Document — BAS (Boash Application System)

> Versi final: tema putih dan navy, kartu membulat, aksen pastel warna-warni, animasi halus.
> Framework: **Flutter (Dart)** · Target awal: `flutter run -d chrome`.
> Prototipe visual acuan: https://claude.ai/artifact/GpHhXbSnmuFd6h3FiJcd2Q

---

## 0. Instruksi Eksekusi (baca dulu)

Bangun aplikasi Flutter sesuai dokumen ini dari awal sampai bisa dijalankan. Urutan kerja:

1. `flutter create bas_student_app` lalu masuk ke foldernya.
2. Tambahkan dependency: `flutter pub add google_fonts`.
3. Buat semua file di bagian 3 dengan isi sesuai bagian 5 sampai 8.
4. Terapkan token desain (warna, font, radius) dari bagian 4 lewat satu file `lib/theme.dart`. Dilarang menulis warna atau ukuran acak di widget.
5. Terapkan animasi di bagian 9 memakai widget bawaan Flutter (`AnimationController`, `TweenAnimationBuilder`, `AnimatedContainer`, `AnimatedSwitcher`). Tidak perlu package animasi tambahan.
6. Jalankan `flutter analyze` sampai bersih, lalu `flutter run -d chrome`.
7. Ambil screenshot Login, Home, Info, Profile, News.

Aturan wajib:
- Latar aplikasi tetap terang. Warna utama navy `#0B1F4B`.
- **Semua icon satu warna** (navy di atas latar terang, putih di atas latar gelap atau gradasi). Warna-warni hanya untuk latar tile, kartu, dan thumbnail, bukan untuk icon.
- Semua teks memakai font Poppins.
- Seluruh teks tampilan berbahasa Indonesia, kecuali label menu Home dan nama tab yang tetap seperti tabel.

---

## 1. Ringkasan Produk

**BAS (Boash Application System)** adalah aplikasi mobile Student App untuk mahasiswa. Alur: halaman login, lalu halaman utama dengan **bottom navigation** empat tab: **Home, Info, Profile, News**.

Tujuan desain: tampilan modern, berwarna tetapi tetap rapi, dan terasa hidup lewat animasi, supaya pengguna tidak bosan.

---

## 2. Arsitektur Navigasi

```
main.dart
  └─ MyApp (MaterialApp, theme dari theme.dart)
       └─ LoginScreen (login.dart)
            │  tombol "Login" → loading 800 ms → pushReplacement (transisi geser naik + fade)
            ▼
       WelcomeScreen (welcome.dart)  ← host bottom navigation melayang
            ├─ Tab 0: HomeScreen    (home.dart)
            ├─ Tab 1: InfoScreen    (info.dart)
            ├─ Tab 2: ProfileScreen (profile.dart)
            └─ Tab 3: NewsScreen    (news.dart)
```

- Login memakai `Navigator.pushReplacement` agar tidak bisa kembali ke login.
- `WelcomeScreen` adalah `StatefulWidget` dengan `_selectedIndex`.
- Isi tab diganti dengan `AnimatedSwitcher` (key = index) supaya animasi masuk tiap tab berulang saat dibuka.

---

## 3. Struktur File

| File | Isi | Tanggung jawab |
|------|-----|----------------|
| `lib/main.dart` | `MyApp` | Entry point, `MaterialApp`, tema, halaman awal `LoginScreen`. |
| `lib/theme.dart` | `AppColors`, `AppText`, `AppTheme` | Semua token desain (warna, font, radius, bayangan). |
| `lib/widgets.dart` | Widget bersama | `RoundIconButton`, `ArrowCircle`, `DarkHeader`, `PillSearch`, `ListRow`, `GradientCard`, `Staggered`, `CountUp`. |
| `lib/login.dart` | `LoginScreen` | Halaman login. |
| `lib/welcome.dart` | `WelcomeScreen` | Host tab dan bottom navigation melayang. |
| `lib/home.dart` | `HomeScreen` | Tab Home. |
| `lib/info.dart` | `InfoScreen` | Tab Info. |
| `lib/profile.dart` | `ProfileScreen` | Tab Profile. |
| `lib/news.dart` | `NewsScreen` | Tab News. |

---

## 4. Token Desain (taruh di `theme.dart`)

### 4.1 Warna

| Nama | Hex | Pemakaian |
|------|-----|-----------|
| `navy` | `#0B1F4B` | Warna utama, teks, icon, tombol, tab aktif |
| `navy2` | `#16306E` | Ujung gradasi header gelap |
| `royal` | `#2447A8` | Ujung gradasi kartu dan tombol navy |
| `bg` | `#EEF1F7` | Latar halaman |
| `card` | `#FFFFFF` | Kartu, nav, field aktif |
| `textSecondary` | `#5B6786` | Teks pendukung |
| `muted` | `#8A94A8` | Placeholder, tab tidak aktif |
| `periwinkle` | `#9DB8FF` | Baris kedua judul header, ring avatar |
| `border` | `#C9D3EA` | Garis tipis |
| `dot` | `#FF5C7A` | Titik notifikasi |

**Pastel (latar tile icon, tag, avatar kecil).** Urutan siklus `pastel[i % 6]`:

`#D6E4FF` biru · `#E6DFFF` ungu · `#D5F2E7` mint · `#FFE4D3` peach · `#FFDDE8` pink · `#FFF1C2` kuning

**Gradasi kartu** (arah kiri atas ke kanan bawah):

| Nama | Dari | Ke |
|------|------|----|
| `g1` biru | `#1E4FD8` | `#5B8BFF` |
| `g2` ungu | `#5B3FD1` | `#9A7BFF` |
| `g3` teal | `#0E8A8C` | `#3CC8B4` |
| `g4` coral | `#E4572E` | `#FF9A6B` |
| `hero` navy | `#0B1F4B` | `#1E3A8A` |
| `overview` | `#D6E4FF` | `#E6DFFF` |

### 4.2 Tipografi (package `google_fonts`, font Poppins)

| Gaya | Ukuran | Bobot |
|------|--------|-------|
| Judul login | 28 | 600, letterSpacing 1 |
| Judul header (Info, News) | 26 | 600, tinggi baris 1.25 |
| Judul sheet login | 19 | 600 |
| Nama (sapaan, profil) | 17 sampai 18 | 600 |
| Judul kartu | 14 | 600 |
| Judul baris/list | 13 | 500 |
| Teks isi | 12 | 400 |
| Caption, label menu, tab | 11 | 400 |
| Angka besar kartu "08" | 46 | 600 |
| Label tab aktif | 13 | 500 |

### 4.3 Bentuk dan jarak

| Elemen | Nilai |
|--------|-------|
| Radius kartu besar (gelap, ringkasan, akses cepat) | 26 |
| Radius kartu gradasi (Info) | 22 |
| Radius baris list | 20 |
| Radius sheet atas (Login, isi header) | 34 (login), 28 (isi tab) |
| Radius pill pencarian | 23 |
| Radius tombol utama | 28 |
| Radius bottom nav | 32 |
| Padding horizontal halaman | 18 |
| Jarak antar kartu | 14 |

### 4.4 Bayangan

- Bottom nav: `BoxShadow(color: navy @16%, blurRadius: 28, offset: (0, 10))`.
- Tombol bulat putih (`RoundIconButton`): `navy @8%, blur 14, offset (0, 4)`.
- Kartu lain: tanpa bayangan.

### 4.5 Icon (Material Icons, satu warna)

| Fungsi | Icon Flutter |
|--------|--------------|
| Home | `Icons.home_outlined` |
| Settings / filter | `Icons.tune` |
| Notifications | `Icons.notifications_none` |
| Profile / user | `Icons.person_outline` |
| Email | `Icons.mail_outline` |
| Phone | `Icons.phone_outlined` |
| Camera | `Icons.photo_camera_outlined` |
| Map | `Icons.location_on_outlined` |
| Cart | `Icons.shopping_cart_outlined` |
| Favorite | `Icons.favorite_border` |
| Music | `Icons.music_note_outlined` |
| Help | `Icons.help_outline` |
| Info | `Icons.info_outline` |
| News | `Icons.article_outlined` |
| Password | `Icons.lock_outline` |
| Logo, kampus, NIM | `Icons.school_outlined` |
| Cari | `Icons.search` |
| Aplikasi | `Icons.apps_rounded` |
| Buku, prodi | `Icons.menu_book_outlined` |
| Kalender | `Icons.calendar_today_outlined` |
| Beasiswa | `Icons.workspace_premium_outlined` |
| Panah tombol | `Icons.arrow_forward` |
| Panah baris | `Icons.chevron_right` |

---

## 5. Widget Bersama (`widgets.dart`)

| Widget | Spesifikasi |
|--------|-------------|
| `RoundIconButton` | Lingkaran 44, putih, icon navy 22, bayangan lembut. Varian `dot: true` menampilkan titik `dot` 8 px di kanan atas dengan animasi ping (lingkaran memudar membesar, ulang tiap 2 detik). |
| `ArrowCircle` | Lingkaran 42 (34 di kartu gradasi), putih, icon `arrow_forward` navy. Saat di-hover atau ditekan, geser 3 px ke kanan. |
| `DarkHeader` | Latar gradasi `navy` → `navy2` (arah 165°), padding `22,18,46,18`, memuat 1 sampai 2 bulatan dekoratif transparan (ungu, teal, atau coral @ 25 sampai 35%) yang bergeser pelan bolak-balik 7 detik. Judul dua baris: baris kedua warna `periwinkle`. |
| `PillSearch` | Tinggi 46, putih, radius 23, icon `search` navy, placeholder `muted` 12, di kanan lingkaran navy 36 berisi icon `tune` putih. Hanya tampilan (tidak perlu fungsi). |
| `SheetBody` | Konten di bawah header: latar `bg`, radius atas 28, ditarik naik 26 px menimpa header, padding atas 20. |
| `ListRow` | Baris putih radius 20, padding 12. Kiri tile 48×48 radius 16 berlatar pastel dengan icon navy. Tengah judul (13/500 navy) dan isi (12 `textSecondary`). Kanan opsional `chevron_right`. Efek tekan: skala 0.97. |
| `GradientCard` | Kartu radius 22, tinggi minimal 128, latar gradasi `g1` sampai `g4`. Kiri atas tile 38 radius 12 putih @22% berisi icon putih. Kiri bawah judul 14/600 dan subjudul 11 (putih @85%). Kanan bawah `ArrowCircle` 34. Bulatan dekoratif putih @13% ukuran 90 di pojok kanan atas. Efek tekan: skala 0.96. |
| `Staggered` | Pembungkus animasi masuk (lihat bagian 9.2). |
| `CountUp` | Teks angka yang menghitung naik dari 0 (lihat bagian 9.3). |

---

## 6. Layar

### 6.1 LoginScreen

- Latar penuh gradasi `hero` (165°). Tiga bulatan buram dekoratif melayang: ungu `#8B5CF6 @35%` (150 px, kiri atas), teal `#2DD4BF @28%` (110 px, kanan atas), coral `#FF9A6B @30%` (90 px, tengah).
- Bagian atas (50% tinggi), rata tengah: logo kotak 80×80 radius 26 putih berisi icon `school_outlined` navy 42, judul "BAS" (putih, 28/600), subjudul "Boash Application System" (`#B9C9F5`, 12).
- Bagian bawah: sheet putih radius atas 34, padding `28,24,30,24`:
  - Judul "Selamat datang kembali" (19/600), teks "Masuk dengan NIM dan password kampus." (12, `textSecondary`).
  - Field NIM (icon `person_outline`, hint `2024010001`) dan Password (icon `lock_outline`, `obscureText: true`). Field: tinggi 50, radius 16, latar `bg`. Saat fokus: garis navy 1.5, latar putih, cincin `#E4EAF8` 4 px.
  - Tombol utama "Login": tinggi 56, radius 28, gradasi navy → royal, teks putih 14/500, subteks "Lanjut ke Student App" 11. Kanan: `ArrowCircle` 42. Saat ditekan: ganti panah dengan spinner (lingkaran 18, garis `border`, busur navy) selama 800 ms, lalu pindah layar.
- Field boleh kosong (ini demo, tanpa validasi server).

### 6.2 WelcomeScreen (host)

- Tanpa AppBar. Judul tampil di tiap tab.
- **Bottom navigation melayang** (widget buatan sendiri, bukan `BottomNavigationBar` bawaan): posisi 14 px dari kiri, kanan, dan bawah; tinggi 64; putih; radius 32; bayangan nav; padding 8.
- Empat tombol, tinggi 48, radius 24. Tab tidak aktif: hanya icon `muted`. Tab aktif: melebar (flex 2.5 banding 1), latar navy, icon putih plus label (13/500) muncul di samping icon.

| Index | Label | Icon | Halaman |
|-------|-------|------|---------|
| 0 | Home | `home_outlined` | `HomeScreen` |
| 1 | Info | `info_outline` | `InfoScreen` |
| 2 | Profile | `person_outline` | `ProfileScreen` |
| 3 | News | `article_outlined` | `NewsScreen` |

- Isi tiap tab diberi padding bawah 104 supaya tidak tertutup nav.
- Toast kecil (navy, putih, radius 20) muncul 1,4 detik di atas nav, 92 px dari bawah.

### 6.3 HomeScreen

Urutan dari atas, semua dalam `ListView`/`SingleChildScrollView`:

1. **Baris atas** (padding `20,18,6,18`): avatar bulat 46 gradasi navy → `#4F7BFF` berisi icon `person_outline` putih. Teks "Selamat pagi," (12) dan "Alina Putri" (17/600). Kanan `RoundIconButton` bel dengan titik.
2. **Kartu "Kelas berikutnya"** (gradasi navy → royal, radius 26, padding 20, margin horizontal 18): label "Kelas berikutnya" (12), angka "08" (46/600), teks "Okt 2026, Kamis" dan "10.30 WIB, Pemrograman Mobile". Di kanan atas ilustrasi: dua lingkaran konsentris garis putih @22% (150 px dan 82 px, yang dalam berisi isian putih @10%) dengan icon `school_outlined` putih 58 di tengah. Ilustrasi melayang naik turun.
3. **Kartu "Ringkasan akademik"** (gradasi `overview`, radius 26, padding 16): judul (13/500) dan chip "Semester 5" (putih @70%, radius 12). Tiga kotak (putih @65%, radius 16, padding 10):

| Label | Nilai | Isi bar |
|-------|-------|---------|
| IPK | 3.8 | 95% |
| SKS | 96 | 67% |
| Hadir | 92% | 92% |

   Angka 22/600 (`CountUp`), bar tinggi 5 radius 3, trek navy @12%, isi navy.
4. **Kartu "Akses cepat"** (putih, radius 26, padding 16): judul lalu grid **4 kolom × 3 baris**, 12 menu. Tiap menu: lingkaran 56 berlatar `pastel[i % 6]`, icon navy 26, label 11 di bawah.

| # | Label | Icon |
|---|-------|------|
| 1 | Home | `home_outlined` |
| 2 | Settings | `tune` |
| 3 | Notifications | `notifications_none` |
| 4 | Profile | `person_outline` |
| 5 | Email | `mail_outline` |
| 6 | Phone | `phone_outlined` |
| 7 | Camera | `photo_camera_outlined` |
| 8 | Map | `location_on_outlined` |
| 9 | Cart | `shopping_cart_outlined` |
| 10 | Favorite | `favorite_border` |
| 11 | Music | `music_note_outlined` |
| 12 | Help | `help_outline` |

   Saat menu disentuh: lingkaran berubah navy, icon putih, naik 4 px dan miring −6°. Saat ditekan: mengecil ke 0.9. Saat diketuk: toast "`<label>` dibuka".

### 6.4 InfoScreen

1. `DarkHeader` dengan judul "Info kampus" / "yang kamu butuhkan" dan `PillSearch` "Cari info, layanan...".
2. `SheetBody`:
   - Grid 2 kolom `GradientCard` (jarak 12):

| Judul | Subjudul | Icon | Gradasi |
|-------|----------|------|---------|
| Akademik | Jadwal dan KRS | `menu_book_outlined` | g1 |
| Beasiswa | Program terbuka | `workspace_premium_outlined` | g2 |
| Kalender | Agenda semester | `calendar_today_outlined` | g3 |
| Peta kampus | Gedung dan ruang | `location_on_outlined` | g4 |

   - Tiga `ListRow` (tile pastel mint, peach, pink):
     - Nama aplikasi: "BAS (Boash Application System)" (`apps_rounded`)
     - Versi: "1.0.0" (`info_outline`)
     - Deskripsi: "Aplikasi mahasiswa dengan tab Home, Info, Profile, dan News." (`menu_book_outlined`)
   - Banner "Tanya admin kampus" (gradasi `overview`, radius 20, padding 14): tiga avatar huruf bertumpuk (A, R, D; pastel biru, peach, mint; border putih 2), teks "Tanya admin kampus" (13/600) dan "Respon dalam 1 jam" (12), kanan `ArrowCircle` 38 berlatar navy dengan panah putih.

### 6.5 ProfileScreen

1. `DarkHeader` tanpa judul, berisi: avatar bulat 96 (putih, border `periwinkle` 4, icon `person_outline` navy 46), nama "Alina Putri" (18/600 putih), "Mahasiswa aktif" (12, `#B9C9F5`). Bulatan dekoratif teal dan coral.
2. `SheetBody`:
   - Kartu statistik putih radius 22, tiga kolom rata tengah: **Semester 5**, **IPK 3.8**, **SKS 96** (angka 20/600 `CountUp`, label 11).
   - Tiga `ListRow` (tile pastel ungu, mint, peach): NIM `2024010001` (`school_outlined`), Program studi "Teknik Informatika" (`menu_book_outlined`), Email `nama@kampus.ac.id` (`mail_outline`).
   - Tombol "Ubah profil" gaya tombol login, subteks "Perbarui data diri".

### 6.6 NewsScreen

1. `DarkHeader` judul "Berita terbaru" / "dari kampus" dan `PillSearch` "Cari berita...".
2. `SheetBody`:
   - Chip filter horizontal: Semua, Akademik, Kegiatan, Info. Chip: radius 20, padding `7,16`, latar putih, teks navy 12. Chip aktif: latar navy, teks putih. Pergantian warna beranimasi 250 ms.
   - Daftar berita memakai `ListRow` dengan thumbnail 60×60 radius 18 berlatar gradasi dan icon putih, tag kategori (radius 8, latar pastel, teks navy 11), tanggal, judul (13/500), ringkasan (12), dan chevron di kanan.

| Kategori | Tanggal | Judul | Ringkasan | Gradasi, icon |
|----------|---------|-------|-----------|---------------|
| Akademik | 09 Okt 2026 | Jadwal ujian semester | Cek ruang dan jam ujianmu. | g1, `menu_book_outlined` |
| Kegiatan | 08 Okt 2026 | Seminar teknologi | Pendaftaran dibuka sampai Jumat. | g2, `workspace_premium_outlined` |
| Info | 07 Okt 2026 | Pembayaran UKT dibuka | Bayar sebelum tenggat agar KRS aktif. | g3, `info_outline` |
| Akademik | 05 Okt 2026 | Pengisian KRS dimulai | Isi KRS lewat portal mahasiswa. | g1, `menu_book_outlined` |
| Kegiatan | 03 Okt 2026 | Lomba coding kampus | Bentuk tim dan daftar hari ini. | g4, `workspace_premium_outlined` |

   - Tag pastel: Akademik biru `#D6E4FF`, Kegiatan ungu `#E6DFFF`, Info mint `#D5F2E7`.
   - Mengganti chip memfilter daftar dan memutar ulang animasi masuk daftar.

---

## 7. Alur Pengguna

1. Buka aplikasi → **Login** (animasi masuk).
2. Tekan "Login" → spinner 800 ms → transisi ke **Home**.
3. Tekan tab di bawah → isi tab berganti dan animasi masuk berputar ulang.
4. Tidak ada jalan kembali ke Login (`pushReplacement`).

---

## 8. Data Contoh

Semua data memakai konstanta lokal (`const`) di masing-masing file. Tidak ada jaringan atau database. Nama contoh: Alina Putri, NIM `2024010001`, Teknik Informatika.

---

## 9. Animasi

Hormati pengaturan aksesibilitas: jika `MediaQuery.of(context).disableAnimations` bernilai true, tampilkan langsung tanpa animasi.

### 9.1 Login

| Elemen | Efek | Durasi dan kurva |
|--------|------|------------------|
| Logo | Skala 0.4 → 1 dan fade in, lalu melayang naik 8 px bolak-balik terus-menerus | 800 ms `Curves.elasticOut`; melayang 4 detik `easeInOut` |
| Bulatan dekoratif | Bergeser (16, 12) dan membesar 1.1× bolak-balik | 7 detik `easeInOut`, fase berbeda tiap bulatan |
| Sheet putih | Naik 60 px dan fade in | 800 ms, tunda 250 ms, `Curves.easeOutCubic` |
| Tombol Login | Panah → spinner 800 ms; ditekan skala 0.97 | 150 ms |
| Transisi ke Home | Login bergeser keluar ke atas sambil fade; Home skala 0.96 → 1 dan fade in | 700 ms |

### 9.2 Muncul bertahap (`Staggered`)

Tiap elemen utama di tab (baris atas, kartu, menu, list) naik 20 px dan fade in, 550 ms, `Curves.easeOutCubic`, tunda `index × 55 ms`. Berjalan setiap tab dibuka dan setiap filter News diganti. Hindari efek ini di tempat selain itu.

### 9.3 Angka dan bar

- `CountUp`: angka naik dari 0 ke nilai akhir selama 900 ms dengan kurva `easeOutCubic` (pertahankan 1 desimal untuk IPK, tambahkan `%` untuk Hadir).
- Bar ringkasan: lebar tumbuh dari 0 ke target selama 1 detik, tunda 500 ms.

### 9.4 Komponen

| Elemen | Efek |
|--------|------|
| Tab di bottom nav | Pil navy melebar dan label muncul (500 ms `easeOutBack`); icon memantul naik 5 px dan membesar 1.15× (500 ms) |
| Ilustrasi kartu Home | Melayang naik turun 9 px, 5 detik |
| Titik notifikasi | Ping: lingkaran memudar membesar, ulang tiap 2 detik |
| Avatar profil | Muncul skala 0.4 → 1 (700 ms `elasticOut`), lalu cincin periwinkle memudar membesar 2 kali |
| Menu akses cepat | Hover naik 4 px dan miring −6°, berubah navy (250 ms); tekan mengecil 0.9 |
| Kartu dan baris | Tekan mengecil 0.96 sampai 0.97 (200 ms) |
| Toast | Naik 20 px dan fade in, 300 ms |
| Field login | Garis dan cincin fokus beranimasi 200 ms |

---

## 10. Aksesibilitas

- Kontras teks navy di atas putih dan pastel sudah memenuhi standar. Teks putih hanya di atas navy atau gradasi gelap.
- Beri `Semantics`/`tooltip` pada tombol icon (bel, tab nav, tombol filter, tombol panah).
- Area ketuk minimal 44×44.
- Font tidak lebih kecil dari 11.

---

## 11. Rencana Eksekusi

| Tahap | Cakupan | Status |
|-------|---------|--------|
| 1. Setup | `flutter create`, tambah `google_fonts`, `theme.dart` | Belum |
| 2. Komponen | `widgets.dart` (bagian 5) | Belum |
| 3. Alur utama | `main.dart`, `login.dart`, `welcome.dart` + bottom nav melayang | Belum |
| 4. Tab | `home.dart`, `info.dart`, `profile.dart`, `news.dart` | Belum |
| 5. Animasi | Bagian 9 di semua layar | Belum |
| 6. Verifikasi | `flutter analyze` + `flutter run -d chrome` | Belum |

---

## 12. Kriteria Hasil (Deliverable)

- `flutter analyze` tanpa error dan peringatan.
- Aplikasi berjalan lewat `flutter run -d chrome`.
- Login → Home berfungsi dengan transisi; empat tab berfungsi dan menampilkan konten berbeda.
- Semua icon satu warna; latar aplikasi terang; font Poppins di semua teks.
- Animasi di bagian 9 terlihat berjalan.
- Tampilan sesuai prototipe acuan.
- Screenshot untuk: **Login, Home, Info, Profile, News**.
