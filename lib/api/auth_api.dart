import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Model data akun dari MockAPI demo.
class UserAccount {
  const UserAccount({
    required this.npm,
    required this.passwordSha1,
    required this.name,
    required this.prodi,
    required this.fakultas,
    required this.semester,
    required this.ipk,
    required this.sks,
    this.email,
    this.avatar,
  });

  final String npm;
  final String passwordSha1;
  final String name;
  final String prodi;
  final String fakultas;
  final int semester;
  final double ipk;
  final int sks;
  final String? email;
  final String? avatar;

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys, {String fallback = ''}) {
      for (final String key in keys) {
        final dynamic value = json[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    return UserAccount(
      npm: readString(<String>['NPM', 'npm']),
      passwordSha1: readString(<String>['Password', 'pass_sha1']),
      name:
          json['Nama']?.toString() ??
          json['nama']?.toString() ??
          json['name']?.toString() ??
          '-',
      prodi:
          json['Prodi']?.toString() ??
          json['prodi']?.toString() ??
          'Teknologi Rekayasa Multimedia',
      fakultas:
          json['Fakultas']?.toString() ??
          json['fakultas']?.toString() ??
          'Teknik',
      semester: (json['Semester'] ?? json['semester'] is int)
          ? (json['Semester'] ?? json['semester']) as int
          : int.tryParse(
                  json['Semester']?.toString() ??
                      json['semester']?.toString() ??
                      '5',
                ) ??
                5,
      ipk: (json['IPK'] ?? json['ipk']) is num
          ? ((json['IPK'] ?? json['ipk']) as num).toDouble()
          : double.tryParse(
                  json['IPK']?.toString() ?? json['ipk']?.toString() ?? '3.80',
                ) ??
                3.80,
      sks: (json['SKS'] ?? json['sks']) is int
          ? (json['SKS'] ?? json['sks']) as int
          : int.tryParse(
                  json['SKS']?.toString() ?? json['sks']?.toString() ?? '96',
                ) ??
                96,
      email: json['Email']?.toString() ?? json['email']?.toString(),
      avatar: json['avatar']?.toString() ?? json['Avatar']?.toString(),
    );
  }
}

/// AuthApi: Autentikasi demo via MockAPI + SHA-1.
///
/// PERINGATAN KEAMANAN: SHA-1 dan pemeriksaan hash di perangkat dari API
/// publik bukan metode autentikasi yang aman untuk produksi. Ini hanya untuk
/// keperluan demo/tugas. Jangan gunakan untuk data mahasiswa sungguhan.
class AuthApi {
<<<<<<< HEAD
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint =
      Uri.parse('https://6adab9277512f497b30020ef.mockapi.io/user');

  final http.Client _client;

  /// Checks submitted NPM and SHA-1 password against the demo API.
  /// Each API record is expected to have "NPM" and "Password" fields.
  Future<bool> authenticate({
    required String npm,
    required String passwordSha1,
  }) async {
    final response = await _client
        .get(_endpoint)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal mengambil data login (HTTP ${response.statusCode})',
      );
=======
  static const String _baseUrl =
      'https://6adab9277512f497b30020ef.mockapi.io/user';

  /// Mengambil seluruh daftar user dari MockAPI demo.
  /// Melempar exception jika HTTP gagal, timeout, atau JSON tidak valid.
  Future<List<UserAccount>> fetchUsers() async {
    final http.Response response = await http
        .get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException('Gagal mengambil data (HTTP ${response.statusCode})');
>>>>>>> f8fc6fe (Revisi)
    }

    final dynamic data = jsonDecode(response.body);
    if (data is! List) {
<<<<<<< HEAD
      throw const FormatException(
        'Respons API login harus berupa daftar user.',
      );
    }

    for (final dynamic item in data) {
      if (item is! Map<String, dynamic>) continue;
      final dynamic apiNpm = item['NPM'];
      final dynamic apiPassword = item['Password'];
      if (apiNpm is String &&
          apiPassword is String &&
          apiNpm.trim() == npm.trim() &&
          apiPassword.trim().toLowerCase() == passwordSha1.toLowerCase()) {
        return true;
      }
    }
    return false;
=======
      throw const FormatException('Format respons API tidak valid');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(UserAccount.fromJson)
        .toList();
  }

  /// Menghitung SHA-1 hex dari string input menggunakan UTF-8.
  /// Implementasi murni Dart tanpa library tambahan.
  ///
  /// CATATAN: SHA-1 tidak aman untuk penyimpanan password. Digunakan hanya
  /// karena kontrak data demo sudah menyimpan hash SHA-1.
  String sha1Hex(String input) {
    final List<int> bytes = utf8.encode(input);
    return _sha1(bytes);
  }

  String _sha1(List<int> message) {
    // Konstanta SHA-1
    const List<int> h = <int>[
      0x67452301,
      0xEFCDAB89,
      0x98BADCFE,
      0x10325476,
      0xC3D2E1F0,
    ];

    int h0 = h[0];
    int h1 = h[1];
    int h2 = h[2];
    int h3 = h[3];
    int h4 = h[4];

    // Pre-processing: padding
    final int originalLength = message.length;
    final int bitLength = originalLength * 8;

    final List<int> padded = List<int>.from(message)..add(0x80);

    while (padded.length % 64 != 56) {
      padded.add(0x00);
    }

    // Append original length sebagai 64-bit big-endian
    for (int i = 7; i >= 0; i--) {
      padded.add((bitLength >> (i * 8)) & 0xFF);
    }

    // Process each 512-bit chunk
    for (int i = 0; i < padded.length; i += 64) {
      final List<int> chunk = padded.sublist(i, i + 64);

      // Break chunk into sixteen 32-bit big-endian words
      final List<int> w = List<int>.filled(80, 0);
      for (int j = 0; j < 16; j++) {
        w[j] =
            (chunk[j * 4] << 24) |
            (chunk[j * 4 + 1] << 16) |
            (chunk[j * 4 + 2] << 8) |
            chunk[j * 4 + 3];
        w[j] = w[j] & 0xFFFFFFFF;
      }
      // Extend the sixteen 32-bit words into eighty 32-bit words
      for (int j = 16; j < 80; j++) {
        final int val = w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16];
        w[j] = _leftRotate(val, 1);
      }

      int a = h0;
      int b = h1;
      int c = h2;
      int d = h3;
      int e = h4;

      for (int j = 0; j < 80; j++) {
        int f;
        int k;
        if (j < 20) {
          f = (b & c) | ((~b) & d);
          k = 0x5A827999;
        } else if (j < 40) {
          f = b ^ c ^ d;
          k = 0x6ED9EBA1;
        } else if (j < 60) {
          f = (b & c) | (b & d) | (c & d);
          k = 0x8F1BBCDC;
        } else {
          f = b ^ c ^ d;
          k = 0xCA62C1D6;
        }

        f &= 0xFFFFFFFF;
        final int temp = (_leftRotate(a, 5) + f + e + k + w[j]) & 0xFFFFFFFF;
        e = d;
        d = c;
        c = _leftRotate(b, 30);
        b = a;
        a = temp;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
    }

    return <int>[
      h0,
      h1,
      h2,
      h3,
      h4,
    ].map((int v) => v.toRadixString(16).padLeft(8, '0')).join();
  }

  int _leftRotate(int n, int shift) {
    n &= 0xFFFFFFFF;
    return ((n << shift) | (n >> (32 - shift))) & 0xFFFFFFFF;
>>>>>>> f8fc6fe (Revisi)
  }

  void close() => _client.close();
}
