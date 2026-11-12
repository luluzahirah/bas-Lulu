# Panduan Seed Data MockAPI (BAS Mobile App)

Dokumen ini menjelaskan struktur data dan langkah-langkah untuk menambahkan resource baru ke MockAPI project:
**Base URL:** `https://6aed363dfc3b911e6fd60ab2.mockapi.io`

---

## 1. Resource yang Dibutuhkan

| Resource | Status | Field |
|---|---|---|
| `/krs` | Sudah ada | `id, npm, kd_matkul, kd_kelas, tahun, tri_semester, thn_akademik, semester, thn_akademik_now, semester_now, group_id_nonreg, status` |
| `/matkul` | Baru | `id, kd_matkul, nama_matkul, sks, semester` |
| `/nilai` | Baru | `id, npm, kd_matkul, thn_akademik, semester, nilai_angka, nilai_huruf, bobot` |
| `/pengajuan_studi` | Baru | `id, npm, jenis, thn_akademik, semester, alasan, status, tanggal_pengajuan, catatan` |

---

## 2. Cara Membuat Resource & Mengisi Data di MockAPI

1. **Login ke akun MockAPI:**
   Buka [mockapi.io](https://mockapi.io) dan login ke akun yang mengelola project endpoint `6aed363dfc3b911e6fd60ab2`.

2. **Membuat Resource `/matkul`:**
   - Klik tombol **"New resource"**.
   - Isi Resource name: `matkul`.
   - Tambahkan Schema:
     - `kd_matkul` (string)
     - `nama_matkul` (string)
     - `sks` (number)
     - `semester` (number/string)
   - Klik **"Create"**.
   - Buka resource `/matkul`, klik **"Data"** atau gunakan endpoint POST untuk mengimpor isi file `seed/matkul.json`.

3. **Membuat Resource `/nilai`:**
   - Klik tombol **"New resource"**.
   - Isi Resource name: `nilai`.
   - Tambahkan Schema:
     - `npm` (string)
     - `kd_matkul` (string)
     - `thn_akademik` (string)
     - `semester` (string/number)
     - `nilai_angka` (number)
     - `nilai_huruf` (string)
     - `bobot` (number)
   - Klik **"Create"**.
   - Buka resource `/nilai`, klik **"Data"** dan masukkan isi data dari file `seed/nilai.json`.

4. **Membuat Resource `/pengajuan_studi`:**
   - Klik tombol **"New resource"**.
   - Isi Resource name: `pengajuan_studi`.
   - Tambahkan Schema:
     - `npm` (string)
     - `jenis` (string)
     - `thn_akademik` (string)
     - `semester` (string/number)
     - `alasan` (string)
     - `status` (string: "pending" / "disetujui" / "ditolak")
     - `tanggal_pengajuan` (string ISO date)
     - `catatan` (string)
   - Klik **"Create"**.
   - Buka resource `/pengajuan_studi`, masukkan data dari `seed/pengajuan_studi.json`.

---

## 3. Otomasi Fallback Lokal Aplikasi

Aplikasi BAS sudah dilengkapi mekanisme **Smart Fallback**:
- Jika resource di MockAPI belum dibuat (merespons HTTP 404) atau server sedang offline, aplikasi secara otomatis menggunakan data dari folder `seed/` ini.
- Ketika resource MockAPI sudah dibuat dan terisi, aplikasi akan langsung tersambung dan menampilkan data live dari MockAPI.
