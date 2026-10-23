# Pertemuan 4 — Auth Flutter

> Dikonversi dari `Pertemuan_4_-_Auth_Flutter.docx`. Gambar pada dokumen asli sudah diubah menjadi teks dan disatukan di sini.

---

## Struktur Folder

(Gambar struktur folder pada dokumen asli, diubah menjadi teks.)

```
lib/
├── api/
│   └── auth_api.dart
├── pages/
│   └── auth_page.dart
└── main.dart
```

---

## main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthPage(),
    );
  }
}
```

---

## auth_api.dart

```dart
// lib/api/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  Future<Map<String, dynamic>?> fetchRandomUser() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'][0]; // ambil 1 user
    } else {
      return null;
    }
  }
}
```

---

## Auth_page.dart

```dart
import 'package:flutter/material.dart';
import '../api/auth_api.dart';

class AuthPage extends StatefulWidget {
  // Widget untuk halaman otentikasi (login)
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
  // Membuat state untuk AuthPage
}

class _AuthPageState extends State<AuthPage> {
  // Controller untuk input username
  final TextEditingController _usernameController = TextEditingController();
  // Controller untuk input password
  final TextEditingController _passwordController = TextEditingController();

  Map<String, dynamic>? _user;
  String? _message;

  @override
  // Menginisialisasi state
  void initState() {
    super.initState();
    _loadUser(); // ambil user saat halaman dibuka
  }

  // Fungsi ambil user
  void _loadUser() async {
    final api = AuthApi();
    // Mengambil user acak dari API
    final user = await api.fetchRandomUser();
    setState(() {
      _user = user;
    });
  }

  // Fungsi untuk proses login
  void _login() {
    if (_user == null) {
      setState(() {
        _message = 'User belum dimuat';
      });
      return;
    }

    // Mendapatkan username dari user API
    final username = _user!['login']['username'];
    // Mendapatkan password dari user API
    final password = _user!['login']['password'];

    // Memeriksa apakah username dan password cocok
    if (_usernameController.text == username &&
        _passwordController.text == password) {
      setState(() {
        _message = 'Login berhasil!';
      });
      // Jika tidak cocok
    } else {
      setState(() {
        _message = 'Username atau password salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan username dan password saat ini untuk ditampilkan
    final currentUsername = _user?['login']?['username'] ?? '-';
    final currentPassword = _user?['login']?['password'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Widget di dalam kolom
          children: [
            const Text('Username'),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // Input untuk password
            const Text('Password'),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),

            // Tombol login
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),

            // Menampilkan pesan
            const SizedBox(height: 20),
            if (_message != null) Text(_message!),

            const Divider(height: 30),
            Text("User login dari API (untuk testing):"),
            Text("Username: $currentUsername"),
            Text("Password: $currentPassword"),

            const SizedBox(height: 10),

            // Tombol untuk mengganti user acak
            ElevatedButton(
              onPressed: _loadUser,
              child: const Text('Ganti User Acak'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Sumber API

<https://randomuser.me/api/>

Cuplikan respons API (gambar pada dokumen asli, diubah menjadi teks). Bagian `login` inilah yang dipakai aplikasi untuk mencocokkan username dan password:

```json
"email": "jagdish.nair@example.com",
"login": {
  "uuid": "79e10ce1-b7e9-4f4a-8496-b845ef4c8dff",
  "username": "organicgorilla759",
  "password": "diane",
  "salt": "RE3J8sNc",
  "md5": "e8061f62aed339d549efaae26f594c48",
  "sha1": "4625e3163686b2ed79b253e31c697faf40f1c7e2",
  "sha256": "44834433de120684620b1a1436e63a358ed392589f60815e57036d0233537470"
},
```
