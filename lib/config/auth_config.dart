/// Konfigurasi autentikasi dan endpoint API BAS.
class AuthConfig {
  AuthConfig._();

  /// Kata sandi default untuk validasi lokal akun mahasiswa,
  /// karena API MockAPI saat ini belum menyediakan kolom password.
  // TODO: ganti dengan field password dari API bila sudah tersedia
  static const String defaultPassword = '123456';

  /// Fallback demo passwords untuk lingkungan pengujian/pengembangan internal
  static const List<String> devFallbackPasswords = <String>[
    defaultPassword,
    'testpass',
    'admin',
  ];

  /// URL dasar endpoint nilai BAS untuk verifikasi pendaftaran NPM
  static const String nilaiApiBaseUrl =
      'https://6adab9277512f497b30020ef.mockapi.io/nilai';
}
