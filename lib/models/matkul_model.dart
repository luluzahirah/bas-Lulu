/// Model data Mata Kuliah dari MockAPI.
/// Endpoint: GET /matkul
/// Field: id, kd_matkul, nama_matkul, sks, semester
class MatkulModel {
  const MatkulModel({
    required this.id,
    required this.kdMatkul,
    required this.namaMatkul,
    required this.sks,
    required this.semester,
  });

  final String id;
  final String kdMatkul;
  final String namaMatkul;
  final int sks;
  final String semester;

  factory MatkulModel.fromJson(Map<String, dynamic> json) {
    return MatkulModel(
      id: json['id']?.toString() ?? '',
      kdMatkul: json['kd_matkul']?.toString() ?? '',
      namaMatkul: json['nama_matkul']?.toString() ?? '',
      sks: json['sks'] is int
          ? json['sks'] as int
          : (int.tryParse(json['sks']?.toString() ?? '') ?? 0),
      semester: json['semester']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kd_matkul': kdMatkul,
        'nama_matkul': namaMatkul,
        'sks': sks,
        'semester': semester,
      };
}
