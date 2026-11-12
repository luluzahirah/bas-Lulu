import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/auth_config.dart';
import '../models/khs_nilai_model.dart';
import '../models/matkul_model.dart';
import '../models/nilai_model.dart';
import 'matkul_service.dart';

/// Exception khusus jika NPM tidak terdaftar di sistem.
class NpmNotFoundException implements Exception {
  const NpmNotFoundException(this.npm);
  final String npm;

  @override
  String toString() => 'NPM $npm tidak terdaftar';
}

/// Item Nilai KHS yang telah digabungkan dengan data [MatkulModel].
class KhsJoinedItem {
  const KhsJoinedItem({
    required this.nilai,
    this.matkul,
  });

  final KhsNilaiModel nilai;
  final MatkulModel? matkul;

  String get id => nilai.id;
  String get npm => nilai.npm;
  String get kdMatkul => nilai.kdMatkul;
  String get namaMatkul =>
      (matkul != null && matkul!.namaMatkul.trim().isNotEmpty)
          ? matkul!.namaMatkul
          : nilai.kdMatkul;
  int get sks => matkul?.sks ?? 3;
  double get nilaiAngka => nilai.nilaiAngka;
  String get nilaiHuruf => nilai.nilaiHuruf;
  double get bobot => nilai.bobot;
  /// Mutu = SKS x Bobot
  double get mutu => sks * bobot;
  String get semester => nilai.semester;
  String get thnAkademik => nilai.thnAkademik;
}

/// Ringkasan KHS (Total SKS, Total Mutu, IP Semester, IPK Kumulatif)
class KhsSummary {
  const KhsSummary({
    required this.totalSks,
    required this.totalMutu,
    required this.ipSemester,
    required this.ipk,
    required this.totalSksKumulatif,
    required this.totalMutuKumulatif,
  });

  final int totalSks;
  final double totalMutu;
  final double ipSemester;
  final double ipk;
  final int totalSksKumulatif;
  final double totalMutuKumulatif;

  String get ipSemesterFormatted => ipSemester.toStringAsFixed(2);
  String get ipkFormatted => ipk.toStringAsFixed(2);
}

/// Fallback lokal hardcoded untuk data nilai KHS
final List<Map<String, dynamic>> _fallbackNilaiJson = <Map<String, dynamic>>[
  {'id': '1', 'npm': '12523030', 'kd_matkul': 'GC101', 'thn_akademik': '2023/2024', 'semester': '1', 'nilai_angka': 86.5, 'nilai_huruf': 'A', 'bobot': 4.0},
  {'id': '2', 'npm': '12523030', 'kd_matkul': 'GC102', 'thn_akademik': '2023/2024', 'semester': '1', 'nilai_angka': 78.0, 'nilai_huruf': 'AB', 'bobot': 3.5},
  {'id': '3', 'npm': '12523030', 'kd_matkul': 'GC103', 'thn_akademik': '2023/2024', 'semester': '1', 'nilai_angka': 88.0, 'nilai_huruf': 'A', 'bobot': 4.0},
  {'id': '4', 'npm': '12523030', 'kd_matkul': 'GC201', 'thn_akademik': '2023/2024', 'semester': '2', 'nilai_angka': 84.0, 'nilai_huruf': 'A', 'bobot': 4.0},
  {'id': '5', 'npm': '12523030', 'kd_matkul': 'GC202', 'thn_akademik': '2023/2024', 'semester': '2', 'nilai_angka': 72.5, 'nilai_huruf': 'B', 'bobot': 3.0},
  {'id': '6', 'npm': '12523030', 'kd_matkul': 'GC336', 'thn_akademik': '2023/2024', 'semester': '2', 'nilai_angka': 80.0, 'nilai_huruf': 'A', 'bobot': 4.0},
  {'id': '7', 'npm': '12523030', 'kd_matkul': 'GC327', 'thn_akademik': '2024/2025', 'semester': '5', 'nilai_angka': 89.0, 'nilai_huruf': 'A', 'bobot': 4.0},
  {'id': '8', 'npm': '12523030', 'kd_matkul': 'GC311', 'thn_akademik': '2024/2025', 'semester': '5', 'nilai_angka': 82.5, 'nilai_huruf': 'A', 'bobot': 4.0},
  {'id': '9', 'npm': '12523030', 'kd_matkul': 'GC319', 'thn_akademik': '2024/2025', 'semester': '5', 'nilai_angka': 77.0, 'nilai_huruf': 'AB', 'bobot': 3.5},
  {'id': '10', 'npm': '12523030', 'kd_matkul': 'GC330', 'thn_akademik': '2024/2025', 'semester': '5', 'nilai_angka': 85.0, 'nilai_huruf': 'A', 'bobot': 4.0},
];

/// Service untuk mengambil data nilai mahasiswa dari API BAS.
class NilaiService {
  NilaiService({
    http.Client? client,
    MatkulService? matkulService,
  })  : _client = client ?? http.Client(),
        _matkulService = matkulService ?? MatkulService();

  final http.Client _client;
  final MatkulService _matkulService;

  /// Base URL endpoint nilai login BAS (tersimpan di satu konstanta/config).
  static const String baseUrl = AuthConfig.nilaiApiBaseUrl;

  // ─── LOGIN AUTH VALIDATION (DILESTARIKAN UNTUK KOMPATIBILITAS AUTH) ────────

  /// Mengambil daftar nilai mahasiswa berdasarkan NPM untuk proses login.
  Future<List<Nilai>> fetchNilai(String npm) async {
    final String cleanNpm = npm.trim();
    if (cleanNpm.isEmpty) {
      throw const FormatException('NPM tidak boleh kosong.');
    }

    final Uri uri = Uri.parse(baseUrl).replace(
      queryParameters: <String, String>{'npm': cleanNpm},
    );

    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const SocketException(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Koneksi waktu habis (timeout). Server sedang lambat merespons.',
      );
    } catch (e) {
      if (e is SocketException || e is TimeoutException) rethrow;
      throw Exception('Gagal menghubungi server: $e');
    }

    if (response.statusCode == 404) {
      throw NpmNotFoundException(cleanNpm);
    }

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal mengambil data nilai dari server (HTTP ${response.statusCode}).',
      );
    }

    final List<Nilai> result = parseResponse(response.body);

    if (result.isEmpty) {
      throw NpmNotFoundException(cleanNpm);
    }

    return result;
  }

  /// Parsing response body baik berupa JSON array langsung `[...]`
  /// maupun envelope `{"value": [...], "Count": n}`.
  static List<Nilai> parseResponse(String responseBody) {
    final String trimmed = responseBody.trim();
    if (trimmed == 'Not found' || trimmed == '"Not found"') {
      return <Nilai>[];
    }

    final dynamic decoded = jsonDecode(trimmed);
    final dynamic rows = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
            ? decoded['value']
            : null;

    if (rows == null) {
      if (decoded is Map<String, dynamic> && decoded.isEmpty) {
        return <Nilai>[];
      }
      throw const FormatException('Format respons API nilai tidak valid');
    }

    if (rows is! List) {
      throw const FormatException('Format respons API nilai tidak valid');
    }

    final List<Nilai> list = <Nilai>[];
    for (final dynamic item in rows) {
      if (item is Map<String, dynamic>) {
        list.add(Nilai.fromJson(item));
      }
    }
    return list;
  }

  // ─── FITUR KHS (KARTU HASIL STUDI) DARI MOCKAPI /nilai ─────────────────────

  /// Mengambil data raw nilai KHS dari base URL MockAPI `/nilai`.
  Future<List<KhsNilaiModel>> fetchKhsNilai({String? npm}) async {
    final String cleanNpm = (npm ?? '').trim();
    final Uri uri = Uri.parse(ApiConfig.nilaiUrl);

    try {
      final http.Response response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final List<KhsNilaiModel> parsed = decoded
              .whereType<Map<String, dynamic>>()
              .map((Map<String, dynamic> item) => KhsNilaiModel.fromJson(item))
              .toList();

          if (parsed.isNotEmpty) {
            return cleanNpm.isEmpty
                ? parsed
                : parsed.where((KhsNilaiModel n) => n.npm == cleanNpm).toList();
          }
        }
      }
    } catch (_) {
      // Fallback ke seed data jika endpoint 404 atau server lambat
    }

    final List<KhsNilaiModel> fallback = await _loadSeedOrFallback();
    return cleanNpm.isEmpty
        ? fallback
        : fallback.where((KhsNilaiModel n) => n.npm == cleanNpm).toList();
  }

  /// Mengambil data KHS yang sudah di-join dengan /matkul serta difilter semester/tahun.
  Future<List<KhsJoinedItem>> fetchJoinedKhs({
    required String npm,
    String? semester,
    String? thnAkademik,
  }) async {
    final Future<List<KhsNilaiModel>> nilaiFuture = fetchKhsNilai(npm: npm);
    final Future<Map<String, MatkulModel>> matkulMapFuture =
        _matkulService.fetchMatkulMap();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      nilaiFuture,
      matkulMapFuture,
    ]);

    final List<KhsNilaiModel> nilaiList = results[0] as List<KhsNilaiModel>;
    final Map<String, MatkulModel> matkulMap =
        results[1] as Map<String, MatkulModel>;

    List<KhsJoinedItem> joined = nilaiList.map((KhsNilaiModel n) {
      final MatkulModel? m = matkulMap[n.kdMatkul.trim().toUpperCase()];
      return KhsJoinedItem(nilai: n, matkul: m);
    }).toList();

    // Filter per semester jika dipilih
    if (semester != null && semester.isNotEmpty && semester != 'Semua') {
      joined = joined
          .where((KhsJoinedItem item) => item.semester == semester)
          .toList();
    }

    // Filter per tahun akademik jika dipilih
    if (thnAkademik != null &&
        thnAkademik.isNotEmpty &&
        thnAkademik != 'Semua') {
      joined = joined
          .where((KhsJoinedItem item) => item.thnAkademik == thnAkademik)
          .toList();
    }

    return joined;
  }

  /// Menghitung ringkasan KHS (Total SKS, Total Mutu, IP Semester, IPK Akumulasi)
  Future<KhsSummary> calculateKhsSummary({
    required String npm,
    required String currentSemester,
    String? currentThnAkademik,
  }) async {
    // 1. Ambil seluruh data nilai mahasiswa untuk akumulasi IPK
    final List<KhsJoinedItem> allJoined = await fetchJoinedKhs(npm: npm);

    // 2. Data semester terpilih
    final List<KhsJoinedItem> semesterJoined = allJoined.where((KhsJoinedItem item) {
      final bool semMatch = item.semester == currentSemester;
      final bool thnMatch = currentThnAkademik == null ||
          currentThnAkademik.isEmpty ||
          currentThnAkademik == 'Semua' ||
          item.thnAkademik == currentThnAkademik;
      return semMatch && thnMatch;
    }).toList();

    // Hitung semester terpilih
    int semSks = 0;
    double semMutu = 0.0;
    for (final KhsJoinedItem item in semesterJoined) {
      semSks += item.sks;
      semMutu += item.mutu;
    }
    final double ips = semSks > 0 ? (semMutu / semSks) : 0.0;

    // Hitung akumulasi seluruh semester (IPK)
    int kumSks = 0;
    double kumMutu = 0.0;
    for (final KhsJoinedItem item in allJoined) {
      kumSks += item.sks;
      kumMutu += item.mutu;
    }
    final double ipk = kumSks > 0 ? (kumMutu / kumSks) : ips;

    return KhsSummary(
      totalSks: semSks,
      totalMutu: semMutu,
      ipSemester: ips,
      ipk: ipk,
      totalSksKumulatif: kumSks,
      totalMutuKumulatif: kumMutu,
    );
  }

  Future<List<KhsNilaiModel>> _loadSeedOrFallback() async {
    try {
      final String content =
          await rootBundle.loadString('assets/seed/nilai.json');
      final dynamic decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> item) => KhsNilaiModel.fromJson(item))
            .toList();
      }
    } catch (_) {}

    return _fallbackNilaiJson
        .map((Map<String, dynamic> item) => KhsNilaiModel.fromJson(item))
        .toList();
  }
}

final NilaiService nilaiService = NilaiService();
