import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/matkul_model.dart';

/// Fallback lokal hardcoded untuk memastikan data matkul selalu tersedia
const List<Map<String, dynamic>> _fallbackMatkulJson = <Map<String, dynamic>>[
  {'id': '1', 'kd_matkul': 'GC327', 'nama_matkul': 'Pemrograman Mobile', 'sks': 3, 'semester': '5'},
  {'id': '2', 'kd_matkul': 'GC311', 'nama_matkul': 'Desain UI/UX', 'sks': 3, 'semester': '5'},
  {'id': '3', 'kd_matkul': 'GC319', 'nama_matkul': 'Rekayasa Perangkat Lunak', 'sks': 3, 'semester': '5'},
  {'id': '4', 'kd_matkul': 'GC330', 'nama_matkul': 'Basis Data Lanjut', 'sks': 3, 'semester': '5'},
  {'id': '5', 'kd_matkul': 'GC336', 'nama_matkul': 'Jaringan Komputer', 'sks': 3, 'semester': '2'},
  {'id': '6', 'kd_matkul': 'GC101', 'nama_matkul': 'Algoritma & Pemrograman', 'sks': 3, 'semester': '1'},
  {'id': '7', 'kd_matkul': 'GC102', 'nama_matkul': 'Matematika Diskrit', 'sks': 2, 'semester': '1'},
  {'id': '8', 'kd_matkul': 'GC103', 'nama_matkul': 'Pengantar Teknologi Informasi', 'sks': 2, 'semester': '1'},
  {'id': '9', 'kd_matkul': 'GC201', 'nama_matkul': 'Struktur Data & Algoritma', 'sks': 3, 'semester': '2'},
  {'id': '10', 'kd_matkul': 'GC202', 'nama_matkul': 'Sistem Operasi', 'sks': 3, 'semester': '2'},
  {'id': '11', 'kd_matkul': 'GC203', 'nama_matkul': 'Pemrograman Berorientasi Objek', 'sks': 3, 'semester': '3'},
  {'id': '12', 'kd_matkul': 'GC301', 'nama_matkul': 'Kecerdasan Buatan', 'sks': 3, 'semester': '5'},
];

/// Service untuk mengelola data Mata Kuliah dari endpoint MockAPI /matkul.
class MatkulService {
  MatkulService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Mengambil daftar seluruh mata kuliah.
  Future<List<MatkulModel>> fetchMatkulList() async {
    final Uri uri = Uri.parse(ApiConfig.matkulUrl);

    try {
      final http.Response response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      // Jika endpoint ada dan sukses
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final List<MatkulModel> parsed = decoded
              .whereType<Map<String, dynamic>>()
              .map((Map<String, dynamic> item) => MatkulModel.fromJson(item))
              .toList();
          if (parsed.isNotEmpty) {
            return parsed;
          }
        }
      }
    } on SocketException {
      // Offline fallback
    } on TimeoutException {
      // Timeout fallback
    } catch (_) {
      // Fallback untuk error lain (misal MockAPI 404 resource belum dibuat)
    }

    // Smart Fallback ke file seed atau data lokal
    return _loadSeedOrFallback();
  }

  /// Mengambil map mata kuliah berdasarkan [kd_matkul] (huruf besar) untuk join cepat.
  Future<Map<String, MatkulModel>> fetchMatkulMap() async {
    final List<MatkulModel> list = await fetchMatkulList();
    final Map<String, MatkulModel> map = <String, MatkulModel>{};
    for (final MatkulModel m in list) {
      map[m.kdMatkul.trim().toUpperCase()] = m;
    }
    return map;
  }

  Future<List<MatkulModel>> _loadSeedOrFallback() async {
    try {
      final String content =
          await rootBundle.loadString('assets/seed/matkul.json');
      final dynamic decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> item) => MatkulModel.fromJson(item))
            .toList();
      }
    } catch (_) {}

    return _fallbackMatkulJson
        .map((Map<String, dynamic> item) => MatkulModel.fromJson(item))
        .toList();
  }
}

final MatkulService matkulService = MatkulService();
