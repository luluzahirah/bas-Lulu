import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../api/auth_api.dart';
import '../config/auth_config.dart';
import '../models/nilai_model.dart';
import '../services/nilai_service.dart';
import '../services/session_service.dart';
import '../welcome.dart';

/// Halaman Login BAS (Boash Application System).
/// Tampilan FIXED: Hero Biru Tua Gelap (#141B3A) + Kartu Login Putih (#FFFFFF).
class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    this.authApi,
    this.nilaiService,
  });

  final AuthApi? authApi;
  final NilaiService? nilaiService;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _canRetry = false;
  bool _isLoggingIn = false;
  bool _isExiting = false;
  bool _obscurePassword = true;

  // Warna fixed tema BAS
  static const Color _scaffoldBg = Color(0xFF0B1024);
  static const Color _heroBg = Color(0xFF141B3A);
  static const Color _heroDecor = Color(0xFF1C2550);
  static const Color _basTitle = Color(0xFF4D6DF0);
  static const Color _basSubtitle = Color(0xFF9AA5D1);
  static const Color _heroHeadline = Color(0xFFEEF1FF);

  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF1D3A9E);
  static const Color _primaryDark = Color(0xFF12246B);
  static const Color _fieldBg = Color(0xFFEEF1FB);
  static const Color _borderColor = Color(0xFFCFD6EE);
  static const Color _textDark = Color(0xFF0F1B4D);
  static const Color _textMuted = Color(0xFF5B6690);

  AuthApi get _api => widget.authApi ?? AuthApi();
  late final NilaiService _nilaiService =
      widget.nilaiService ?? NilaiService();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Memvalidasi kata sandi dengan konstanta konfigurasi terpisah
  bool _isPasswordValid(String password) {
    final String trimmed = password.trim();
    if (trimmed == AuthConfig.defaultPassword) {
      return true;
    }
    // Fallback akun demo dev
    if (AuthConfig.devFallbackPasswords.contains(trimmed)) {
      return true;
    }
    return false;
  }

  /// Mendapatkan akun user untuk sesi login
  UserAccount _resolveUserAccount(String identifier, String inputHash) {
    const UserAccount defaultUser = AuthApi.defaultDemoUser;
    final String cleanId = identifier.trim();

    if (cleanId == defaultUser.npm ||
        cleanId.toLowerCase() == 'admin' ||
        cleanId.toLowerCase() == 'demo' ||
        cleanId.toLowerCase().contains('sofi')) {
      return defaultUser;
    }

    return UserAccount(
      npm: cleanId,
      passwordSha1: inputHash,
      name: defaultUser.name,
      loginName: defaultUser.loginName,
      prodi: defaultUser.prodi,
      fakultas: defaultUser.fakultas,
      semester: defaultUser.semester,
      ipk: defaultUser.ipk,
      sks: defaultUser.sks,
    );
  }

  /// Alur proses autentikasi via API (Tugas 5)
  Future<void> _login() async {
    if (_isLoggingIn) return;

    final String identifier = _identifierController.text.trim();
    final String password = _passwordController.text;

    // 1. Validasi input tidak kosong
    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = 'NPM atau Email tidak boleh kosong.';
        _canRetry = false;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Kata sandi tidak boleh kosong.';
        _canRetry = false;
      });
      return;
    }

    // 2. Deteksi format email: API hanya mengenal NPM
    if (identifier.contains('@')) {
      setState(() {
        _errorMessage = 'Login email belum tersedia, gunakan NPM';
        _canRetry = false;
      });
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
      _canRetry = false;
    });

    try {
      List<Nilai> nilaiList = <Nilai>[];

      // 3. Panggil API dengan NPM yang diinput
      try {
        nilaiList = await _nilaiService.fetchNilai(identifier);
      } on NpmNotFoundException {
        // Response array kosong / 404 -> NPM tidak terdaftar
        if (!mounted) return;
        setState(() {
          _isLoggingIn = false;
          _errorMessage = 'NPM tidak terdaftar';
          _canRetry = false;
        });
        return;
      }

      // 4. Ada data -> verifikasi kata sandi
      if (!_isPasswordValid(password)) {
        if (!mounted) return;
        setState(() {
          _isLoggingIn = false;
          _errorMessage = 'Kata sandi salah';
          _canRetry = false;
        });
        return;
      }

      // 5. Sukses -> simpan sesi & navigasi ke Student App
      final String inputHash = _api.sha1Hex(password);
      final UserAccount matchedUser = _resolveUserAccount(identifier, inputHash);

      SessionService.instance.saveSession(
        npm: matchedUser.npm.isNotEmpty ? matchedUser.npm : identifier,
        user: matchedUser,
        nilaiList: nilaiList,
      );

      if (!mounted) return;

      final bool disabled = MediaQuery.of(context).disableAnimations;
      if (!disabled) {
        setState(() => _isExiting = true);
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: disabled
              ? Duration.zero
              : const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => WelcomeScreen(user: matchedUser),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            if (disabled) return child;
            final CurvedAnimation curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        _canRetry = true;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _errorMessage =
            'Waktu koneksi habis. Server sedang lambat merespons. Silakan coba lagi.';
        _canRetry = true;
      });
    } on HttpException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _errorMessage = 'Gangguan server (${e.message}). Silakan coba lagi.';
        _canRetry = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _errorMessage = 'Terjadi kesalahan saat memproses login: $e';
        _canRetry = true;
      });
    }
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: _primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: AnimatedOpacity(
        opacity: _isExiting ? 0.0 : 1.0,
        duration: disabled ? Duration.zero : const Duration(milliseconds: 200),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // 1. Bagian Atas (Hero) - Biru Tua Gelap (#141B3A)
                        _buildHero(),

                        // 2. Kartu Login Putih (#FFFFFF) menumpuk di bawah hero
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -28),
                            child: _buildLoginCard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 1. Bagian Atas (Hero) dengan Latar Biru Tua Gelap #141B3A
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      color: _heroBg,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 54),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Lingkaran dekorasi besar tipis di pojok kiri atas hero (#1C2550)
          Positioned(
            top: -46,
            left: -46,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _heroDecor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Lingkaran dekorasi besar tipis di kanan bawah hero (#1C2550)
          Positioned(
            bottom: -24,
            right: -36,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _heroDecor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Konten Hero
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Logo BAS dengan glow/bayangan biru lembut di bawahnya
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x404D6DF0),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/logo/bas_icon.svg',
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),

                // Tulisan "BAS" (biru terang #4D6DF0, tebal w700, ukuran 30, letterSpacing 2)
                const Text(
                  'BAS',
                  style: TextStyle(
                    color: _basTitle,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),

                // "Boash Application System" (warna #9AA5D1, ukuran 13)
                const Text(
                  'Boash Application System',
                  style: TextStyle(
                    color: _basSubtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Headline "Permudah akses nilai & kehadiran Anda." (warna #EEF1FF, w600, ukuran 15, rata tengah)
                const Text(
                  'Permudah akses nilai & kehadiran Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _heroHeadline,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Kartu Login (Login Card Container) Putih #FFFFFF
  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _cardBg, // WAJIB putih #FFFFFF di semua kondisi
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Judul "Masuk ke BAS" — RATA KIRI, warna hitam #000000, tebal (w700), ukuran 20
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Masuk ke BAS',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Dua tombol outline berdampingan (Email & Google)
          Row(
            children: <Widget>[
              // Tombol Email
              Expanded(
                child: _AlternativeLoginButton(
                  iconWidget: const Icon(
                    Icons.mail_outline_rounded,
                    size: 19,
                    color: _primary,
                  ),
                  label: 'Email',
                  onTap: () {
                    // TODO: Integrasi login alternatif Email
                    _showNotice('Login alternatif Email segera hadir.');
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Tombol Google (logo Google asli 4 warna, ukuran 18)
              Expanded(
                child: _AlternativeLoginButton(
                  iconWidget: SvgPicture.asset(
                    'assets/icons/google_g.svg',
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  label: 'Google',
                  onTap: () {
                    // TODO: Integrasi login alternatif Google
                    _showNotice('Login alternatif Google segera hadir.');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Pemisah "Atau"
          const Row(
            children: <Widget>[
              Expanded(child: Divider(color: _borderColor, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'Atau',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: _borderColor, thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Label "NPM / Email" (ukuran 12, w400, warna #5B6690) & Kolom isian
          _buildInputLabel('NPM / Email'),
          const SizedBox(height: 6),
          _buildInputField(
            controller: _identifierController,
            icon: Icons.badge_outlined,
            placeholder: 'Contoh: 12523030',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enabled: !_isLoggingIn,
          ),
          const SizedBox(height: 16),

          // 5. Label "Kata Sandi" (ukuran 12, w400, warna #5B6690) & Kolom isian
          _buildInputLabel('Kata Sandi'),
          const SizedBox(height: 6),
          _buildInputField(
            controller: _passwordController,
            icon: Icons.lock_outline,
            placeholder: 'Masukkan kata sandi',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !_isLoggingIn,
            onSubmitted: (_) => _login(),
            // Ikon mata: biasa saat sandi tersembunyi, dicoret saat sandi terlihat
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: _textMuted,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),

          // 6. Link "Lupa kata sandi": rata kanan, biru #1D3A9E, w600, ukuran 13
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showNotice(
                  'Hubungi bagian BAAK/IT Kampus untuk reset kata sandi Anda.',
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lupa kata sandi',
                style: TextStyle(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Banner Error jika ada
          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC0C8)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (_canRetry) ...<Widget>[
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: _login,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 7. Tombol "Masuk": gradasi horizontal #12246B ke #1D3A9E, teks putih w600 ukuran 16, radius 16, tinggi 50
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[_primaryDark, _primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: _isLoggingIn ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoggingIn
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 8. "Belum punya akun? " (hitam) + link "Klik disini untuk daftar" (biru #1D3A9E w600)
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(color: Color(0xFF000000)),
                  ),
                  TextSpan(
                    text: 'Klik disini untuk daftar',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _showNotice(
                          'Pendaftaran akun mahasiswa dilakukan melalui Biro Akademik Kampus.',
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 9. Teks kecil rata tengah abu kebiruan #5B6690, ukuran 11, dua frasa link biru #1D3A9E w600
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  height: 1.45,
                ),
                children: <InlineSpan>[
                  const TextSpan(
                    text: 'Dengan menggunakan layanan kami, Anda berarti setuju atas ',
                  ),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _showNotice('Membuka Syarat & Ketentuan BAS.');
                      },
                  ),
                  const TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi BAS',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _showNotice('Membuka Kebijakan Privasi BAS.');
                      },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 10. Footer "Copyright © 2026 BAS", ukuran 11, abu kebiruan #5B6690
          const Text(
            'Copyright © 2026 BAS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Label kolom input: ukuran 12, w400, warna abu kebiruan #5B6690
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Kolom isian: background #EEF1FB, border #CFD6EE, radius 14, ikon #1D3A9E, teks #0F1B4D
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    bool obscureText = false,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: _primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              enabled: enabled,
              textInputAction: textInputAction,
              keyboardType: keyboardType,
              onSubmitted: onSubmitted,
              cursorColor: _primary,
              style: const TextStyle(
                color: _textDark,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: _textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          ?suffixIcon,
        ],
      ),
    );
  }
}

/// Dua tombol outline berdampingan (Email & Google)
class _AlternativeLoginButton extends StatelessWidget {
  const _AlternativeLoginButton({
    required this.iconWidget,
    required this.label,
    required this.onTap,
  });

  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F1B4D),
        side: const BorderSide(color: Color(0xFFCFD6EE), width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          iconWidget,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F1B4D),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
