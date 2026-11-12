/// Model data Nilai KHS dari MockAPI.
/// Endpoint: GET /nilai
/// Field: id, npm, kd_matkul, thn_akademik, semester, nilai_angka, nilai_huruf, bobot
class KhsNilaiModel {
  const KhsNilaiModel({
    required this.id,
    required this.npm,
    required this.kdMatkul,
    required this.thnAkademik,
    required this.semester,
    required this.nilaiAngka,
    required this.nilaiHuruf,
    required this.bobot,
  });

  final String id;
  final String npm;
  final String kdMatkul;
  final String thnAkademik;
  final String semester;
  final double nilaiAngka;
  final String nilaiHuruf;
  final double bobot;

  /// Standar skala bobot BAS:
  /// A = 4.0, AB = 3.5, B = 3.0, BC = 2.5, C = 2.0, D = 1.0, E = 0.0
  static double bobotFromHuruf(String huruf) {
    switch (huruf.trim().toUpperCase()) {
      case 'A':
        return 4.0;
      case 'AB':
      case 'A/B':
      case 'B+':
        return 3.5;
      case 'B':
        return 3.0;
      case 'BC':
      case 'B/C':
      case 'C+':
        return 2.5;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      case 'E':
      default:
        return 0.0;
    }
  }

  factory KhsNilaiModel.fromJson(Map<String, dynamic> json) {
    final String huruf = json['nilai_huruf']?.toString() ?? '';
    final double? rawBobot = json['bobot'] is num
        ? (json['bobot'] as num).toDouble()
        : double.tryParse(json['bobot']?.toString() ?? '');

    final double bobotVal = rawBobot ?? bobotFromHuruf(huruf);

    final double angkaVal = json['nilai_angka'] is num
        ? (json['nilai_angka'] as num).toDouble()
        : (double.tryParse(json['nilai_angka']?.toString() ?? '') ?? 0.0);

    return KhsNilaiModel(
      id: json['id']?.toString() ?? '',
      npm: json['npm']?.toString() ?? '',
      kdMatkul: json['kd_matkul']?.toString() ?? '',
      thnAkademik: json['thn_akademik']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      nilaiAngka: angkaVal,
      nilaiHuruf: huruf,
      bobot: bobotVal,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'npm': npm,
        'kd_matkul': kdMatkul,
        'thn_akademik': thnAkademik,
        'semester': semester,
        'nilai_angka': nilaiAngka,
        'nilai_huruf': nilaiHuruf,
        'bobot': bobot,
      };
}
