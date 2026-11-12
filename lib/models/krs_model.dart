/// Model data KRS dari MockAPI.
/// Endpoint: GET /krs
/// Field: id, npm, kd_matkul, kd_kelas, tahun, tri_semester, thn_akademik,
/// semester, thn_akademik_now, semester_now, group_id_nonreg, status
class KrsModel {
  const KrsModel({
    required this.id,
    required this.npm,
    required this.kdMatkul,
    required this.kdKelas,
    this.tahun,
    this.triSemester,
    required this.thnAkademik,
    required this.semester,
    this.thnAkademikNow,
    this.semesterNow,
    this.groupIdNonreg,
    required this.status,
  });

  final String id;
  final String npm;
  final String kdMatkul;
  final String kdKelas;
  final String? tahun;
  final String? triSemester;
  final String thnAkademik;
  final String semester;
  final String? thnAkademikNow;
  final String? semesterNow;
  final int? groupIdNonreg;
  final int status; // 1 = Aktif, 0 = Tidak Aktif

  bool get isActive => status == 1;

  factory KrsModel.fromJson(Map<String, dynamic> json) {
    return KrsModel(
      id: json['id']?.toString() ?? '',
      npm: json['npm']?.toString() ?? '',
      kdMatkul: json['kd_matkul']?.toString() ?? '',
      kdKelas: json['kd_kelas']?.toString() ?? '',
      tahun: json['tahun']?.toString(),
      triSemester: json['tri_semester']?.toString(),
      thnAkademik: json['thn_akademik']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      thnAkademikNow: json['thn_akademik_now']?.toString(),
      semesterNow: json['semester_now']?.toString(),
      groupIdNonreg: json['group_id_nonreg'] is int
          ? json['group_id_nonreg'] as int
          : int.tryParse(json['group_id_nonreg']?.toString() ?? ''),
      status: json['status'] is int
          ? json['status'] as int
          : (int.tryParse(json['status']?.toString() ?? '') ?? 0),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'npm': npm,
        'kd_matkul': kdMatkul,
        'kd_kelas': kdKelas,
        'tahun': tahun,
        'tri_semester': triSemester,
        'thn_akademik': thnAkademik,
        'semester': semester,
        'thn_akademik_now': thnAkademikNow,
        'semester_now': semesterNow,
        'group_id_nonreg': groupIdNonreg,
        'status': status,
      };
}
