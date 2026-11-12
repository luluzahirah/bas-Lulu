import '../models/nilai_model.dart';
import '../services/nilai_service.dart';

export '../models/nilai_model.dart';
export '../services/nilai_service.dart';

/// Service adapter untuk mengambil data nilai dari MockAPI demo.
/// Endpoint: GET /nilai?npm={npm}
class NilaiApi {
  final NilaiService _service = NilaiService();

  /// Mengambil daftar nilai berdasarkan NPM mahasiswa.
  /// Jika NPM tidak ditemukan (404/empty), mengembalikan list kosong.
  Future<List<NilaiItem>> fetchNilai(String npm) async {
    try {
      return await _service.fetchNilai(npm);
    } on NpmNotFoundException {
      return <NilaiItem>[];
    }
  }

  /// Menerima format array langsung dan envelope `{"value": [...], ...}`
  static List<NilaiItem> parseResponse(String body) {
    return NilaiService.parseResponse(body);
  }
}
