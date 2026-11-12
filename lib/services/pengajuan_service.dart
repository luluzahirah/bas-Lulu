import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pengajuan_studi_model.dart';

/// Fallback lokal hardcoded untuk pengajuan studi
final List<Map<String, dynamic>> _initialLocalPengajuan = <Map<String, dynamic>>[
  {
    'id': '1',
    'npm': '12523030',
    'jenis': 'Cuti',
    'thn_akademik': '2024/2025',
    'semester': '4',
    'alasan': 'Mengikuti program magang industri bersertifikat di luar kota selama satu semester.',
    'status': 'disetujui',
    'tanggal_pengajuan': '2024-08-10T08:30:00.000Z',
    'catatan': 'Disetujui oleh Kepala Program Studi dan BAAK.',
  },
  {
    'id': '2',
    'npm': '12523030',
    'jenis': 'Aktif Kembali',
    'thn_akademik': '2024/2025',
    'semester': '5',
    'alasan': 'Telah menyelesaikan masa cuti magang industri dan siap melanjutkan perkuliahan aktif.',
    'status': 'pending',
    'tanggal_pengajuan': '2024-09-02T10:15:00.000Z',
    'catatan': 'Menunggu verifikasi berkas administrasi akademik.',
  },
  {
    'id': '3',
    'npm': '12523030',
    'jenis': 'Pindah',
    'thn_akademik': '2023/2024',
    'semester': '2',
    'alasan': 'Mengajukan permohonan alih kelas dari sesi reguler pagi ke sesi malam/karyawan.',
    'status': 'ditolak',
    'tanggal_pengajuan': '2024-01-20T14:45:00.000Z',
    'catatan': 'Kuota kelas karyawan untuk semester tersebut sudah penuh.',
  },
];

/// Service untuk mengelola pengajuan studi ke endpoint MockAPI /pengajuan_studi.
class PengajuanService {
  PengajuanService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Local cache store untuk memfasilitasi penambahan dan pembatalan saat offline/MockAPI 404
  static final List<PengajuanStudiModel> _localCache = <PengajuanStudiModel>[];
  static bool _seedLoaded = false;

  /// Mengambil daftar riwayat pengajuan berdasarkan [npm], diurutkan terbaru dahulu.
  Future<List<PengajuanStudiModel>> fetchPengajuanList({String? npm}) async {
    final String cleanNpm = (npm ?? '').trim();
    final Uri uri = Uri.parse(ApiConfig.pengajuanUrl);

    try {
      final http.Response response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final List<PengajuanStudiModel> remoteList = decoded
              .whereType<Map<String, dynamic>>()
              .map((Map<String, dynamic> item) =>
                  PengajuanStudiModel.fromJson(item))
              .toList();

          if (remoteList.isNotEmpty) {
            _syncLocalCacheWith(remoteList);
            return _filterAndSort(remoteList, cleanNpm);
          }
        }
      }
    } catch (_) {
      // Fallback ke local cache / seed data jika endpoint 404 atau offline
    }

    await _ensureSeedLoaded();
    return _filterAndSort(_localCache, cleanNpm);
  }

  /// Mengirimkan pengajuan studi baru via HTTP POST.
  Future<PengajuanStudiModel> submitPengajuan({
    required String npm,
    required String jenis,
    required String thnAkademik,
    required String semester,
    required String alasan,
  }) async {
    final String cleanAlasan = alasan.trim();
    if (cleanAlasan.length < 10) {
      throw const FormatException(
        'Alasan pengajuan studi minimal 10 karakter.',
      );
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'npm': npm.trim(),
      'jenis': jenis.trim(),
      'thn_akademik': thnAkademik.trim(),
      'semester': semester.trim(),
      'alasan': cleanAlasan,
      'status': 'pending',
      'tanggal_pengajuan': DateTime.now().toUtc().toIso8601String(),
      'catatan': 'Menunggu konfirmasi admin BAAK',
    };

    final Uri uri = Uri.parse(ApiConfig.pengajuanUrl);

    try {
      final http.Response response = await _client
          .post(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final PengajuanStudiModel created =
              PengajuanStudiModel.fromJson(decoded);
          _localCache.insert(0, created);
          return created;
        }
      }
    } catch (_) {
      // Jika server belum membuat resource / offline, simpan di cache lokal
    }

    await _ensureSeedLoaded();
    final String nextId =
        (DateTime.now().millisecondsSinceEpoch % 100000).toString();
    final Map<String, dynamic> localPayload = Map<String, dynamic>.from(payload)
      ..['id'] = nextId;

    final PengajuanStudiModel fallbackCreated =
        PengajuanStudiModel.fromJson(localPayload);
    _localCache.insert(0, fallbackCreated);
    return fallbackCreated;
  }

  /// Membatalkan pengajuan (DELETE) hanya jika statusnya masih "pending".
  Future<bool> deletePengajuan(String id) async {
    final String cleanId = id.trim();
    if (cleanId.isEmpty) return false;

    // Cek status di cache terlebih dahulu jika ada
    final int existingIndex =
        _localCache.indexWhere((PengajuanStudiModel item) => item.id == cleanId);
    if (existingIndex != -1) {
      if (!_localCache[existingIndex].isPending) {
        throw const FormatException(
          'Hanya pengajuan dengan status "pending" yang dapat dibatalkan.',
        );
      }
    }

    final Uri uri = Uri.parse('${ApiConfig.pengajuanUrl}/$cleanId');

    try {
      final http.Response response =
          await _client.delete(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _localCache
            .removeWhere((PengajuanStudiModel item) => item.id == cleanId);
        return true;
      }
    } catch (_) {
      // Lanjutkan hapus dari memori lokal jika server 404/offline
    }

    if (existingIndex != -1) {
      _localCache.removeAt(existingIndex);
      return true;
    }

    return true;
  }

  List<PengajuanStudiModel> _filterAndSort(
    List<PengajuanStudiModel> source,
    String cleanNpm,
  ) {
    List<PengajuanStudiModel> list = List<PengajuanStudiModel>.from(source);
    if (cleanNpm.isNotEmpty) {
      list = list
          .where((PengajuanStudiModel item) => item.npm == cleanNpm)
          .toList();
    }

    // Urutkan terbaru: berdasarkan tanggal_pengajuan descending
    list.sort((PengajuanStudiModel a, PengajuanStudiModel b) {
      final DateTime? dateA = DateTime.tryParse(a.tanggalPengajuan);
      final DateTime? dateB = DateTime.tryParse(b.tanggalPengajuan);
      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA);
      }
      return b.id.compareTo(a.id);
    });

    return list;
  }

  Future<void> _ensureSeedLoaded() async {
    if (_seedLoaded && _localCache.isNotEmpty) return;
    _seedLoaded = true;

    try {
      final String content =
          await rootBundle.loadString('assets/seed/pengajuan_studi.json');
      final dynamic decoded = jsonDecode(content);
      if (decoded is List) {
        _localCache.clear();
        _localCache.addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map((Map<String, dynamic> item) =>
                  PengajuanStudiModel.fromJson(item)),
        );
        return;
      }
    } catch (_) {}

    _localCache.clear();
    _localCache.addAll(
      _initialLocalPengajuan
          .map((Map<String, dynamic> item) => PengajuanStudiModel.fromJson(item)),
    );
  }

  void _syncLocalCacheWith(List<PengajuanStudiModel> remoteList) {
    _localCache.clear();
    _localCache.addAll(remoteList);
    _seedLoaded = true;
  }
}

final PengajuanService pengajuanService = PengajuanService();
