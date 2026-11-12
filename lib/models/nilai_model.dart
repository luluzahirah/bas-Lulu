/// Model data Nilai dari MockAPI BAS.
/// Endpoint: GET https://6adab9277512f497b30020ef.mockapi.io/nilai?npm={npm}
class Nilai {
  const Nilai({
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
    this.naUas = 0,
    this.naUts = 0,
    this.naQuis = 0,
    this.naTugas = 0,
    this.naHadir = 0,
    this.bmanual,
    this.tahun,
    this.triSemester,
    this.cuserid,
    this.dentry,
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
  final double mutu; // Mutu = SKS x am
  final String nip;
  final String thnAkademik;
  final int semester;
  final double seminar;
  final double bimbingan;
  final double makalah;
  final double lisan;
  final double naUas;
  final double naUts;
  final double naQuis;
  final double naTugas;
  final double naHadir;
  final String? bmanual;
  final String? tahun;
  final String? triSemester;
  final String? cuserid;
  final String? dentry;

  factory Nilai.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().trim()) ?? 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString().trim()) ?? 0;
    }

    String? parseNullableString(dynamic v) {
      if (v == null) return null;
      final String s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return Nilai(
      id: parseInt(json['id']),
      kdMatkul: json['kd_matkul']?.toString().trim() ?? '-',
      npm: json['npm']?.toString().trim() ?? '',
      uas: parseD(json['uas']),
      uts: parseD(json['uts']),
      quis: parseD(json['quis']),
      tugas: parseD(json['tugas']),
      hadir: parseD(json['hadir']),
      na: parseD(json['na']),
      hm: json['hm']?.toString().trim() ?? '-',
      am: parseD(json['am']),
      mutu: parseD(json['mutu']),
      nip: json['nip']?.toString().trim() ?? '-',
      thnAkademik: json['thn_akademik']?.toString().trim() ?? '-',
      semester: parseInt(json['semester']),
      seminar: parseD(json['seminar']),
      bimbingan: parseD(json['bimbingan']),
      makalah: parseD(json['makalah']),
      lisan: parseD(json['lisan']),
      naUas: parseD(json['na_uas']),
      naUts: parseD(json['na_uts']),
      naQuis: parseD(json['na_quis']),
      naTugas: parseD(json['na_tugas']),
      naHadir: parseD(json['na_hadir']),
      bmanual: parseNullableString(json['bmanual']),
      tahun: parseNullableString(json['tahun']),
      triSemester: parseNullableString(json['tri_semester']),
      cuserid: parseNullableString(json['cuserid']),
      dentry: parseNullableString(json['dentry']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'kd_matkul': kdMatkul,
    'npm': npm,
    'uas': uas.toString(),
    'uts': uts.toString(),
    'quis': quis.toString(),
    'tugas': tugas.toString(),
    'hadir': hadir.toString(),
    'na': na.toString(),
    'hm': hm,
    'am': am.toString(),
    'mutu': mutu.toString(),
    'nip': nip,
    'thn_akademik': thnAkademik,
    'semester': semester.toString(),
    'seminar': seminar.toString(),
    'bimbingan': bimbingan.toString(),
    'makalah': makalah.toString(),
    'lisan': lisan.toString(),
    'bmanual': bmanual,
    'tahun': tahun,
    'tri_semester': triSemester,
    'cuserid': cuserid,
    'dentry': dentry,
  };

  /// Warna representasi huruf mutu
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

/// Alias untuk kompatibilitas kode lama
typedef NilaiItem = Nilai;
