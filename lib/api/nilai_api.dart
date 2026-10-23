import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Model satu baris nilai mata kuliah dari MockAPI.
class NilaiItem {
  const NilaiItem({
    required this.id,
    required this.kdMatkul,
    required this.npm,
    required this.uas,
    required this.uts,
    required this.quis,
    required this.tugas,
    required this.hadir,
    required this.na,
    required this.hm,
    required this.am,
    required this.mutu,
    required this.nip,
    required this.thnAkademik,
    required this.semester,
    this.seminar = 0,
    this.bimbingan = 0,
    this.makalah = 0,
    this.lisan = 0,
  });

  final int id;
  final String kdMatkul;
  final String npm;
  final double uas;
  final double uts;
  final double quis;
  final double tugas;
  final double hadir;
  final double na; // Nilai Akhir
  final String hm; // Huruf Mutu (A, B+, B, dst)
  final double am; // Angka Mutu
  final double mutu; // Mutu = SKS × am
  final String nip; // NIP dosen
  final String thnAkademik;
  final int semester;
  final double seminar;
  final double bimbingan;
  final double makalah;
  final double lisan;

  factory NilaiItem.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return NilaiItem(
      id: parseInt(json['id']),
      kdMatkul: json['kd_matkul']?.toString() ?? '-',
      npm: json['npm']?.toString() ?? '',
      uas: parseD(json['uas']),
      uts: parseD(json['uts']),
      quis: parseD(json['quis']),
      tugas: parseD(json['tugas']),
      hadir: parseD(json['hadir']),
      na: parseD(json['na']),
      hm: json['hm']?.toString() ?? '-',
      am: parseD(json['am']),
      mutu: parseD(json['mutu']),
      nip: json['nip']?.toString() ?? '-',
      thnAkademik: json['thn_akademik']?.toString() ?? '-',
      semester: parseInt(json['semester']),
      seminar: parseD(json['seminar']),
      bimbingan: parseD(json['bimbingan']),
      makalah: parseD(json['makalah']),
      lisan: parseD(json['lisan']),
    );
  }

  /// Kembalikan warna berdasarkan huruf mutu.
  static const Map<String, int> _hurufColorMap = <String, int>{
    'A': 0xFF22C55E,
    'B': 0xFF3B82F6,
    'C': 0xFFF59E0B,
    'D': 0xFFFF5C7A,
    'E': 0xFFFF5C7A,
  };

  int get hurufColorValue =>
      _hurufColorMap[hm.isNotEmpty ? hm[0].toUpperCase() : ''] ?? 0xFF8A94A8;
}

/// Service untuk mengambil data nilai dari MockAPI demo.
///
/// Endpoint: GET /nilai?npm={npm}
///
/// CATATAN: API publik, data tidak terenkripsi. Hanya untuk demo.
class NilaiApi {
  static const String _host = '6adab9277512f497b30020ef.mockapi.io';
  static const String _path = '/nilai';

  /// Mengambil daftar nilai berdasarkan NPM mahasiswa.
  /// Melempar exception jika HTTP gagal atau JSON tidak valid.
  Future<List<NilaiItem>> fetchNilai(String npm) async {
    final Uri uri = Uri.https(_host, _path, <String, String>{'npm': npm});
    final http.Response response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal mengambil data nilai (HTTP ${response.statusCode})',
      );
    }

    return parseResponse(response.body);
  }

  /// Menerima format array langsung dan envelope `{"value": [...], ...}`
  /// yang dikembalikan endpoint MockAPI nilai.
  static List<NilaiItem> parseResponse(String body) {
    final dynamic decoded = jsonDecode(body);
    final dynamic rows = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
        ? decoded['value']
        : null;

    if (rows is! List) {
      throw const FormatException('Format respons API nilai tidak valid');
    }

    final List<NilaiItem> items = <NilaiItem>[];
    for (final dynamic row in rows) {
      if (row is! Map<String, dynamic>) {
        throw const FormatException('Baris data nilai tidak valid');
      }
      items.add(NilaiItem.fromJson(row));
    }
    return items;
  }
}
