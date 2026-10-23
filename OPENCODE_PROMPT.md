# Prompt OpenCode — Audit dan Revisi BAS Student App

Kamu adalah senior Flutter engineer. Kerjakan langsung pada repository lokal `bas-Lulu` (GitHub: https://github.com/luluzahirah/bas-Lulu). Aplikasi ini demo mobile mahasiswa dengan Edlink dari SEVIMA sebagai referensi UX, bukan untuk menyalin aset/identitas.

## Aturan kerja
1. Baca `REVISI.md`, `WORKFLOW.md`, `README.md`, `pubspec.yaml`, semua source di `lib/`, dan konfigurasi platform relevan.
2. Periksa status git dan perubahan pengguna. Jangan menimpa perubahan tak terkait.
3. Terapkan perbaikan terarah; pertahankan desain/arsitektur yang masih layak.
4. Bedakan fitur aktif, UI demo, dan fitur yang membutuhkan backend. Jangan mengarang endpoint/data/hasil tes.
5. Jangan menampilkan password/hash pada layar, log, atau error.
6. Jangan klaim build/test lulus sebelum menjalankan perintah dan memeriksa output.

## A. Audit
Validasi implementasi terhadap `REVISI.md` dan `WORKFLOW.md`; perbarui dokumen jika source aktual berbeda. Catat bug, prioritas, dampak, solusi, dan hasil verifikasi.

## B. Login NPM + SHA-1
Endpoint: `https://6adab9277512f497b30020ef.mockapi.io/user`.
- Verifikasi respons aktual dan field `NPM` serta `Password`.
- Hapus `randomuser.me` dari login.
- Input pertama NPM; input kedua password.
- Hitung SHA-1 dari password UTF-8 lalu cocokkan dengan field Password (diasumsikan hash SHA-1 hex).
- Tangani input kosong, HTTP error, timeout, koneksi, JSON malformed, daftar kosong, dan kredensial salah.
- Cegah submit ganda, tampilkan loading, dan gunakan pesan login gagal yang tidak membocorkan apakah NPM terdaftar.
- Pisahkan API dari UI dan injeksikan `http.Client`.
- Tambahkan unit test mock client: sukses, kredensial salah, format respons salah, HTTP error, dan timeout jika memungkinkan.
- SHA-1 dan validasi daftar akun di perangkat hanya untuk demo. Produksi memerlukan backend HTTPS, password hashing modern di server, dan token sesi.

## C. Bottom navigation
Urutan wajib: `Home → Info → News → Profile`. Profile selalu paling kanan. Pastikan daftar tab dan halaman sinkron.

## D. UI/UX
- Gunakan design tokens `lib/theme.dart`.
- Perbaiki label NPM/password, show/hide password, loading/error/empty state, kontras, ukuran teks, area sentuh, dan overflow layar kecil.
- Semua tombol/tile harus beraksi nyata atau menjelaskan bahwa itu demo.
- Jangan menampilkan data akademik palsu seolah data sungguhan.
- Pertahankan navy/biru dan Poppins jika sesuai.
- Audit lifecycle controller, timer, animation controller, dan HTTP client.

## E. Validasi
Jalankan `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, dan bila memungkinkan `flutter build apk --debug`. Perbaiki error dari perubahanmu. Jika command tidak dapat dijalankan, jelaskan dan jangan klaim lulus.

## Output akhir
Sertakan file berubah, ringkasan perbaikan, perintah dan hasil test/build, serta keterbatasan tersisa. Jangan commit/push kecuali diminta.
