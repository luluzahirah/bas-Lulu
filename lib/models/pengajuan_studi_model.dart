/// Model data Pengajuan Studi dari MockAPI.
/// Endpoint: /pengajuan_studi
/// Field: id, npm, jenis, thn_akademik, semester, alasan, status,
/// tanggal_pengajuan, catatan
class PengajuanStudiModel {
  const PengajuanStudiModel({
    required this.id,
    required this.npm,
    required this.jenis,
    required this.thnAkademik,
    required this.semester,
    required this.alasan,
    required this.status,
    required this.tanggalPengajuan,
    this.catatan = '-',
  });

  final String id;
  final String npm;
  final String jenis; // 'Cuti', 'Aktif Kembali', 'Pindah', 'Mengundurkan Diri'
  final String thnAkademik;
  final String semester;
  final String alasan;
  final String status; // 'pending', 'disetujui', 'ditolak'
  final String tanggalPengajuan; // ISO date string
  final String catatan;

  bool get isPending => status.trim().toLowerCase() == 'pending';
  bool get isDisetujui => status.trim().toLowerCase() == 'disetujui';
  bool get isDitolak => status.trim().toLowerCase() == 'ditolak';

  factory PengajuanStudiModel.fromJson(Map<String, dynamic> json) {
    return PengajuanStudiModel(
      id: json['id']?.toString() ?? '',
      npm: json['npm']?.toString() ?? '',
      jenis: json['jenis']?.toString() ?? '',
      thnAkademik: json['thn_akademik']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      alasan: json['alasan']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      tanggalPengajuan: json['tanggal_pengajuan']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
      catatan: json['catatan']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'npm': npm,
        'jenis': jenis,
        'thn_akademik': thnAkademik,
        'semester': semester,
        'alasan': alasan,
        'status': status,
        'tanggal_pengajuan': tanggalPengajuan,
        'catatan': catatan,
      };
}
