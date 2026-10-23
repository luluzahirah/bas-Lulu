# BAS Student App

Aplikasi Flutter demo layanan mahasiswa dengan navigasi Beranda, Jadwal,
Akademik, Pengumuman, dan Profil.

## Menjalankan aplikasi

Pastikan Flutter SDK tersedia, lalu jalankan dari direktori proyek:

```bash
flutter pub get
flutter run
```

Untuk membuat APK debug:

```bash
flutter build apk --debug
```

## Fitur akademik

- Akademik menyediakan Materi, Tugas, Nilai, Presensi, KTM, KRS, dan akses ke
  layanan DHS.
- Buka **Akademik > DHS > DHS Kuliah** untuk melihat nilai mata kuliah yang
  dikelompokkan berdasarkan semester. Baris nilai menampilkan kode mata kuliah,
  UAS, UTS, nilai akhir, huruf mutu, angka mutu, dan rincian komponen yang
  tersedia.
- DHS Kuliah mengambil data dari
  `https://6adab9277512f497b30020ef.mockapi.io/nilai?npm={npm}`. Endpoint demo
  mengembalikan envelope `value` dan `Count`; aplikasi menerima format tersebut
  serta array JSON langsung.
- Referensi konsep DHS/KHS dan informasi nilai semester:
  [Google: Daftar Hasil Studi mahasiswa per semester](https://www.google.com/search?q=Daftar+Hasil+Studi+DHS+KHS+mahasiswa+nilai+semester+IPK).

Nama mata kuliah, jumlah SKS, IPK/IPS resmi, dan identitas lain tidak
direkayasa apabila tidak tersedia dari respons API. Endpoint nilai hanya
menyediakan data demo dan bukan sumber transkrip resmi.

## Login dan batasan demo

Login demo memakai endpoint terpisah
`https://6adab9277512f497b30020ef.mockapi.io/user` sesuai kontrak NPM dan
password SHA-1. Record akun harus menyertakan NPM (`NPM` atau `npm`) dan hash
password (`Password` atau `pass_sha1`). Login menolak record yang tidak
memiliki kedua field tersebut dan menampilkan petunjuk konfigurasi. Endpoint
`/nilai` berisi nilai dan bukan endpoint autentikasi, sehingga tidak digunakan
untuk memverifikasi login.

MockAPI publik dan SHA-1 tidak aman untuk produksi. Jangan gunakan data atau
mekanisme demo ini untuk autentikasi maupun informasi akademik resmi.
