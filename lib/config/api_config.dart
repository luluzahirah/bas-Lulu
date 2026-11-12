import 'dart:io';
import 'package:flutter/services.dart';

/// Konfigurasi endpoint API dan pembaca variabel lingkungan (.env).
class ApiConfig {
  ApiConfig._();

  /// Default Base URL MockAPI untuk resource KRS, Matkul, Nilai, Pengajuan Studi
  static const String defaultBaseUrl =
      'https://6aed363dfc3b911e6fd60ab2.mockapi.io';

  static String _baseUrl = const String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: defaultBaseUrl,
  );

  static bool _initialized = false;

  /// Mengembalikan Base URL yang sedang aktif.
  static String get baseUrl => _baseUrl;

  /// Endpoint URLs
  static String get krsUrl => '$_baseUrl/krs';
  static String get matkulUrl => '$_baseUrl/matkul';
  static String get nilaiUrl => '$_baseUrl/nilai';
  static String get pengajuanUrl => '$_baseUrl/pengajuan_studi';

  /// Inisialisasi konfigurasi dari file .env (jika ada)
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Coba baca dari rootBundle asset (.env)
    try {
      final String content = await rootBundle.loadString('.env');
      _parseEnv(content);
      return;
    } catch (_) {
      // Lewati jika belum dimuat lewat bundle
    }

    // 2. Coba baca langsung dari filesystem lokal (.env)
    try {
      final File file = File('.env');
      if (file.existsSync()) {
        final String content = file.readAsStringSync();
        _parseEnv(content);
        return;
      }
    } catch (_) {
      // Abaikan pada web sandbox / runtime tanpa file access
    }
  }

  /// Override Base URL secara manual (berguna untuk testing atau konfigurasi dinamis)
  static void setBaseUrl(String url) {
    String clean = url.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _baseUrl = clean;
  }

  /// Reset ke Base URL default
  static void resetBaseUrl() {
    _baseUrl = defaultBaseUrl;
  }

  static void _parseEnv(String content) {
    for (final String line in content.split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final int equalsIndex = trimmed.indexOf('=');
      if (equalsIndex > 0) {
        final String key = trimmed.substring(0, equalsIndex).trim();
        final String value = trimmed.substring(equalsIndex + 1).trim();
        if (key == 'BASE_API_URL' && value.isNotEmpty) {
          setBaseUrl(value);
        }
      }
    }
  }
}
