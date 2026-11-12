import '../api/auth_api.dart';
import '../models/nilai_model.dart';

/// Mengelola sesi login pengguna aktif (NPM + data nilai + profil akun).
class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  String? _npm;
  UserAccount? _currentUser;
  List<Nilai> _nilaiList = <Nilai>[];

  String? get npm => _npm;
  UserAccount? get currentUser => _currentUser;
  List<Nilai> get nilaiList => List<Nilai>.unmodifiable(_nilaiList);
  bool get isLoggedIn => _npm != null && _npm!.isNotEmpty;

  /// Simpan sesi login baru
  void saveSession({
    required String npm,
    required UserAccount user,
    required List<Nilai> nilaiList,
  }) {
    _npm = npm;
    _currentUser = user;
    _nilaiList = List<Nilai>.from(nilaiList);
  }

  /// Hapus sesi saat logout
  void clearSession() {
    _npm = null;
    _currentUser = null;
    _nilaiList = <Nilai>[];
  }
}
