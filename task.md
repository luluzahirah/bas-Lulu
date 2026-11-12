# TASK — Redesign Halaman Login BAS (Boash Application System)

> Baca `design.md` terlebih dahulu. Semua warna, font, radius, dan spacing HARUS mengacu ke design.md (tema biru BAS). Jangan hardcode warna baru jika token sudah ada.

## Referensi
- Layout referensi: halaman login Edlink (Siakad / Google, "Atau", Alamat Email, Kata Sandi, Lupa kata sandi, tombol Masuk, Belum punya akun, syarat & ketentuan).
- Warna: biru BAS dari `design.md` (BUKAN hijau Edlink).
- API login: `https://6adab9277512f497b30020ef.mockapi.io/nilai?npm=12523030`

## Temuan API (sudah dicek)
- Response berupa array data **nilai** (field: `id, kd_matkul, npm, uas, uts, quis, tugas, hadir, hm, na, am, mutu, thn_akademik, semester, ...`).
- Query `?npm=...` mengembalikan array; jika NPM tidak ada → array kosong `[]` (atau 404 tergantung mockapi).
- **Tidak ada field `password` maupun `nama`** di API ini.
- Keputusan: NPM divalidasi lewat API (array tidak kosong = NPM terdaftar). Password diverifikasi lokal (default demo `123456`) karena API tidak menyediakannya. Nama mahasiswa tetap diambil dari konfigurasi/akun demo yang sudah ada (`Sofi Putri Rahayu`).

---

## TASK 1 — Redesign tampilan login ala Edlink dengan warna biru BAS
- [x] Baca `design.md`, catat token warna primer/sekunder, font, radius, shadow.
- [x] Bagian atas: ilustrasi/hero singkat + headline (mis. "Permudah akses nilai & kehadiran Anda."), dekorasi bentuk/dot ala Edlink dengan warna biru BAS.
- [x] Bagian form: logo BAS, judul "Masuk ke BAS".
- [x] Dua tombol alternatif outline berdampingan (mis. "Siakad" dan "Google") — boleh hanya tampilan (non-fungsional) kecuali sudah ada backend; tandai jelas di kode dengan TODO.
- [x] Divider "Atau".
- [x] Field "NPM / Username" dengan ikon kiri, field "Kata Sandi" dengan ikon kiri + toggle show/hide.
- [x] Link "Lupa kata sandi" rata kanan (warna biru primer).
- [x] Tombol "Masuk" full-width, warna biru primer, state loading & disabled.
- [x] Teks "Belum punya akun? Klik disini untuk daftar" (placeholder navigasi).
- [x] Teks syarat & ketentuan kecil di bawah.
- [x] Footer "Copyright © 2026 BAS".
- [x] Responsif: tampil baik di layar mobile (≈360–430px) tanpa overflow.

## TASK 2 — Hapus kartu "Akun Demo" dan perbaiki overflow
- [x] Hapus seluruh kartu "Akun Demo (Siap Pakai)" (gambar no. 3), termasuk tombol "Gunakan Akun Demo", daftar NPM/Password, dan teks petunjuknya.
- [x] Hapus kode/state/handler yang hanya dipakai kartu itu (mis. fungsi isi form otomatis).
- [x] Pastikan tidak ada banner kuning-hitam "RIGHT OVERFLOWED BY 8.4 PIXELS" lagi (cek semua `Row` / lebar teks, gunakan `Expanded`/`Flexible`/`Wrap`).
- [x] Credential demo tetap dipertahankan di logika (config/konstanta), hanya UI-nya yang dihapus.

## TASK 3 — Hapus link "Buka Aplikasi QR Attendance (Pertemuan 6)" dari halaman login
- [x] Hapus tombol/teks tersebut dari halaman login.
- [x] Pastikan fitur QR Attendance tetap bisa diakses dari dalam aplikasi (setelah login). Jika belum ada entry point di dalam app, laporkan, jangan hapus fiturnya.
- [x] Bersihkan import/route yang tidak terpakai di halaman login.

## TASK 4 — Buat logo aplikasi BAS (referensi Edlink)
- [x] Buat logo BAS: ikon topi toga (graduation cap) + maskot/elemen sederhana ala Edlink, warna biru BAS dari `design.md`, plus wordmark "BAS" dan subjudul "Boash Application System".
- [x] Buat sebagai SVG (vektor) di `assets/logo/` : `bas_logo.svg` (ikon + wordmark), `bas_icon.svg` (ikon saja).
- [x] Jika framework butuh PNG, ekspor PNG 512x512 dan 1024x1024 transparan.
- [x] Daftarkan aset di konfigurasi proyek (mis. `pubspec.yaml` / folder assets) dan pakai di halaman login.
- [x] (Opsional) Terapkan sebagai ikon launcher/favicon aplikasi.

## TASK 5 — Integrasi API sebagai data login
- [x] Buat service/repository: `GET https://6adab9277512f497b30020ef.mockapi.io/nilai?npm={npm}`. Simpan base URL di satu konstanta.
- [x] Alur login:
  1. Validasi input tidak kosong.
  2. Panggil API dengan NPM yang diinput.
  3. Jika response array kosong / 404 → tampilkan "NPM tidak terdaftar".
  4. Jika ada data → cek password lokal (`123456`, atau akun demo `admin / testpass`).
  5. Jika password salah → "Password salah".
  6. Jika sukses → simpan sesi (NPM + daftar nilai) dan navigasi ke Student App.
- [x] Parsing model `Nilai` dari JSON (perhatikan: angka berupa string, `bmanual` bisa null).
- [x] Penanganan error: timeout, tidak ada internet, server error → pesan ramah + tombol coba lagi.
- [x] Loading indicator pada tombol Masuk.
- [x] Gunakan data dari API untuk halaman nilai di Student App bila sudah ada layar tersebut (hindari data dummy).
- [x] Jangan hardcode data hasil API.

## TASK 6 — QA / Verifikasi
- [x] Login NPM `12523030` + `123456` berhasil.
- [x] NPM acak (mis. `99999999`) → pesan "tidak terdaftar".
- [x] Password salah → pesan error.
- [x] Tidak ada overflow warning di berbagai ukuran layar.
- [x] Tidak ada kartu Akun Demo & tidak ada link QR Attendance di login.
- [x] Warna sesuai `design.md`.
- [x] Jalankan analyzer/lint/build tanpa error.

## Catatan untuk Pengembang
- Password tidak tersedia di API → pertimbangkan menambah resource `users` di MockAPI (`npm`, `nama`, `password`) agar login benar-benar berbasis API.
- Jangan simpan password plaintext di produksi; ini hanya untuk demo.
