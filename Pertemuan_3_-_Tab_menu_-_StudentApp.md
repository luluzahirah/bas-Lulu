# Pertemuan 3 - Tab Menu - Student App

> Konversi dari file Word `Pertemuan_3_-_Tab_menu_-_StudentApp.docx`.
> Mata kuliah/modul: Basic Mobile Apps (Flutter), Boash University.
> Judul bagian di modul: **DEVELOPMENT BASIC BOASH APPLICATION SYSTEM (BAS)** dan **DEVELOPMENT ADVANCED STUDENT APP**.

---

## Ringkasan Tugas (untuk AI)

- Framework: **Flutter** (bahasa Dart).
- Aplikasi memiliki alur: `main.dart` -> `login.dart` -> `welcome.dart` (tab menu dengan 4 tab) -> `home.dart` / `info.dart` / `profile.dart` / `news.dart`.
- Tab menu dibuat dengan `BottomNavigationBar` di `welcome.dart`, berisi empat tab: **Home, Info, Profile, News**.
- Cara menjalankan: `flutter run -d chrome`
- Bagian Basic: kode sudah diberikan di modul (lihat bagian 1).
- Bagian Advanced: desain ulang `home.dart` (12 menu icon berwarna), lalu desain `info.dart`, `profile.dart`, `news.dart` sendiri.
- Hasil yang dikumpulkan: screenshot Login, Home, Info, Profile, dan News.

---

## Bagian 1. DEVELOPMENT BASIC (BAS)

Struktur proyek Flutter dengan file: `main.dart`, `login.dart`, `welcome.dart`, `home.dart`, `info.dart`, `profile.dart`, `news.dart`.
Tab menu ada di `welcome.dart` dan terdiri dari empat tab: Home, Info, Profile, dan News.

### 1.1 main.dart

```dart
import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
```

### 1.2 login.dart

```dart
import 'package:flutter/material.dart';
import 'welcome.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
```

### 1.3 welcome.dart

```dart
import 'package:flutter/material.dart';
import 'home.dart';
import 'info.dart';
import 'profile.dart';
import 'news.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    InfoScreen(),
    ProfileScreen(),
    NewsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student App',
          style: TextStyle(
            color: Color.fromARGB(255, 246, 246, 248), // Warna teks
            fontWeight: FontWeight.bold, // Memberikan gaya tebal pada teks
            fontSize: 24, // Ukuran teks
          ),
        ),
        centerTitle: true, // Untuk memusatkan teks judul
        backgroundColor: Colors.blueAccent, // Warna latar belakang AppBar
        elevation: 4, // Memberikan bayangan pada AppBar
        shadowColor: Colors.black.withOpacity(0.5), // Warna bayangan
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        onTap: _onItemTapped,
      ),
    );
  }
}
```

### 1.4 home.dart

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab'),
    );
  }
}
```

### 1.5 info.dart

```dart
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Info Tab'),
    );
  }
}
```

### 1.6 profile.dart

```dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Tab'),
    );
  }
}
```

### 1.7 news.dart

```dart
import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('News Tab'),
    );
  }
}
```

### 1.8 Penjelasan dari modul

- **main.dart** berfungsi sebagai entry point aplikasi.
- **login.dart** adalah halaman login. Setelah login, aplikasi menuju `WelcomeScreen`.
- **Cara menjalankan:** `flutter run -d chrome`
- **welcome.dart** memiliki empat tab: Home, Info, Profile, dan News. Setiap tab menampilkan konten berbeda sesuai file `home.dart`, `info.dart`, `profile.dart`, dan `news.dart`.
- Tab diatur menggunakan `BottomNavigationBar` (di `welcome.dart`), dengan setiap tab merujuk ke halamannya masing-masing.

### 1.9 Gambar di modul (deskripsi)

Modul memuat gambar berikut pada bagian ini:

1. **Gambar 1 - Terminal CMD.** Perintah yang dijalankan di folder `D:\__Programmer__ Kerja\Boash University\Basic Mobile Apps`: `code .` lalu `flutter create bas`. Hasilnya: proyek `bas` dibuat (130 file), lalu ada petunjuk `cd bas` dan `flutter run`. Kode utama ada di `bas\lib\main.dart`.
2. **Gambar 2 - "Hasilnya adalah".** Tampilan VS Code (kiri) dan Chrome di `localhost:57318` (kanan). Di folder `lib` ada: `home.dart`, `info.dart`, `login.dart`, `main.dart`, `news.dart`, `profile.dart`, `welcome.dart`. Terminal menjalankan `flutter run -d chrome`. Aplikasi menampilkan AppBar biru "Student App" dan tab News aktif dengan teks "News Tab" di tengah. Empat ikon tab berada di bawah (Home, Info, Profile, News).

---

## Bagian 2. DEVELOPMENT ADVANCED - STUDENT APP

### 2.1 home.dart

1. Blok kode yang ada di `home.dart` di-cut (Ctrl + X).
2. Buka ChatGPT, lalu masukkan prompt dengan format berikut (kode lama ditempel setelah kalimat prompt):

```text
buatkan code di file home.dart untuk membuat contoh 12 menu icon warna seperti code dibawah ini

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab'),
    );
  }
}
```

3. Salin kode hasil dari ChatGPT ke dalam file `home.dart`.

**Tampilan output (Gambar 3 di modul):** Dibuat di Project IDX (idx.google.com, project "studentapp") dengan emulator Android.
- AppBar biru berjudul "Student App" dan teks "Welcome My Student Apps" di bawahnya.
- Grid ikon bulat berwarna dengan 3 kolom (`crossAxisCount: 3`, `crossAxisSpacing: 10`, `mainAxisSpacing: 10`, `GridView.builder`).
- Daftar menu di kode contoh (`menuItems`, berisi map dengan kunci `icon`, `color`, `label`):
  Home (merah), Settings (biru), Notifications (oranye), Profile (hijau), Email (ungu), Phone (teal), Camera (pink), Map (amber), Cart/shopping_cart (indigo), Favorite (redAccent), Music/music_note (lightGreen), Help (deepPurple).
- Tab navigasi bawah (Home, Info, Profile, News) tetap tampil.

### 2.2 Tab lainnya

- Lanjutkan desain `info.dart`, `profile.dart`, dan `news.dart` sesuai keinginan, dengan teknik yang sama seperti `home.dart` (minta dibuatkan kode ke ChatGPT berdasarkan kode lama, lalu tempel ke file).
- Lakukan desain sebaik mungkin.

---

## Bagian 3. Tugas dan Pengumpulan

- Tugas: **screenshot** hasil aplikasi dari halaman **Login, Home, Info, Profile, dan News**.
- Buat **link Google Drive** berisi folder-folder dengan **nama siswa**. Di dalam tiap folder ada hasil screenshot.
- **Batas pengumpulan: jam 12:00 WIB.**
- Link Google Drive dikirim ke nomor WhatsApp yang ditentukan.
