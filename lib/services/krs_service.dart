import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/krs_model.dart';
import '../models/matkul_model.dart';
import 'matkul_service.dart';

/// Item KRS yang telah digabung (join) dengan data [MatkulModel].
class KrsJoinedItem {
  const KrsJoinedItem({
    required this.krs,
    this.matkul,
  });

  final KrsModel krs;
  final MatkulModel? matkul;

  String get id => krs.id;
  String get npm => krs.npm;
  String get kdMatkul => krs.kdMatkul;
  String get namaMatkul =>
      (matkul != null && matkul!.namaMatkul.trim().isNotEmpty)
          ? matkul!.namaMatkul
          : krs.kdMatkul;
  int get sks => matkul?.sks ?? 3;
  String get kdKelas => krs.kdKelas.isNotEmpty ? krs.kdKelas : 'A';
  String get semester => krs.semester;
  String get thnAkademik => krs.thnAkademik;
  int get status => krs.status;
  bool get isActive => krs.isActive;
}

/// Service untuk mengelola data KRS dari endpoint MockAPI /krs.
class KrsService {
  KrsService({
    http.Client? client,
    MatkulService? matkulService,
  })  : _client = client ?? http.Client(),
        _matkulService = matkulService ?? MatkulService();

  final http.Client _client;
  final MatkulService _matkulService;

  /// Mengambil daftar raw KRS dari MockAPI berdasarkan [npm].
  Future<List<KrsModel>> fetchKrs({String? npm}) async {
    final String cleanNpm = (npm ?? '').trim();
    final Uri uri = Uri.parse(ApiConfig.krsUrl);

    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on SocketException {
      // Coba fallback seed data offline jika tidak ada jaringan
      final List<KrsModel> fallback = await _loadSeedKrs();
      if (fallback.isNotEmpty) {
        return cleanNpm.isEmpty
            ? fallback
            : fallback.where((KrsModel k) => k.npm == cleanNpm).toList();
      }
      throw const SocketException(
        'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Waktu permintaan habis (timeout). Server lambat merespons.',
      );
    } catch (e) {
      if (e is SocketException || e is TimeoutException) rethrow;
      throw Exception('Gagal menghubungi server KRS: $e');
    }

    if (response.statusCode != 200) {
      final List<KrsModel> fallback = await _loadSeedKrs();
      if (fallback.isNotEmpty) {
        return cleanNpm.isEmpty
            ? fallback
            : fallback.where((KrsModel k) => k.npm == cleanNpm).toList();
      }
      throw HttpException(
        'Gagal mengambil data KRS (HTTP ${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : <dynamic>[];

    final List<KrsModel> allItems = list
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => KrsModel.fromJson(item))
        .toList();

    if (cleanNpm.isEmpty) {
      return allItems;
    }
    return allItems.where((KrsModel item) => item.npm == cleanNpm).toList();
  }

  /// Mengambil data KRS yang sudah di-join dengan data /matkul.
  Future<List<KrsJoinedItem>> fetchJoinedKrs({
    String? npm,
    String? thnAkademik,
    String? semester,
    String? searchQuery,
  }) async {
    final Future<List<KrsModel>> krsFuture = fetchKrs(npm: npm);
    final Future<Map<String, MatkulModel>> matkulMapFuture =
        _matkulService.fetchMatkulMap();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      krsFuture,
      matkulMapFuture,
    ]);

    final List<KrsModel> krsList = results[0] as List<KrsModel>;
    final Map<String, MatkulModel> matkulMap =
        results[1] as Map<String, MatkulModel>;

    List<KrsJoinedItem> joined = krsList.map((KrsModel krs) {
      final MatkulModel? matkul = matkulMap[krs.kdMatkul.trim().toUpperCase()];
      return KrsJoinedItem(krs: krs, matkul: matkul);
    }).toList();

    // Filter tahun akademik jika dipilih
    if (thnAkademik != null &&
        thnAkademik.isNotEmpty &&
        thnAkademik != 'Semua') {
      joined = joined
          .where((KrsJoinedItem item) => item.thnAkademik == thnAkademik)
          .toList();
    }

    // Filter semester jika dipilih
    if (semester != null && semester.isNotEmpty && semester != 'Semua') {
      joined = joined
          .where((KrsJoinedItem item) => item.semester == semester)
          .toList();
    }

    // Filter pencarian (kode atau nama matkul)
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final String query = searchQuery.trim().toLowerCase();
      joined = joined.where((KrsJoinedItem item) {
        final bool matchKode = item.kdMatkul.toLowerCase().contains(query);
        final bool matchNama = item.namaMatkul.toLowerCase().contains(query);
        return matchKode || matchNama;
      }).toList();
    }

    return joined;
  }

  /// Memuat data seed lokal sebagai cadangan
  Future<List<KrsModel>> _loadSeedKrs() async {
    try {
      final String data = await rootBundle.loadString('assets/seed/krs.json');
      final dynamic decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> item) => KrsModel.fromJson(item))
            .toList();
      }
    } catch (_) {}
    return <KrsModel>[];
  }
}

final KrsService krsService = KrsService();
