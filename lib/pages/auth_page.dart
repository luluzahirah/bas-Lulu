import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../theme.dart';
import '../welcome.dart';
import 'home_page.dart';

/// AuthPage: halaman login demo menggunakan MockAPI + NPM + SHA-1.
///
/// PERINGATAN KEAMANAN: SHA-1 dan pemeriksaan hash di perangkat dari API
/// publik BUKAN autentikasi yang aman untuk produksi. Ini hanya untuk demo.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.authApi});

  final AuthApi? authApi;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoggingIn = false;
  bool _isExiting = false;
  bool _loginPressed = false;

  late final AnimationController _logo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final AnimationController _sheet = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController _decor = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  AuthApi get _api => widget.authApi ?? AuthApi();

  @override
  void initState() {
    super.initState();
    _logo.forward();
    _float.repeat(reverse: true);
    _decor.repeat(reverse: true);
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _sheet.forward();
    });
  }

  @override
  void dispose() {
    _npmController.dispose();
    _passwordController.dispose();
    _logo.dispose();
    _float.dispose();
    _sheet.dispose();
    _decor.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoggingIn) return;

    final String npm = _npmController.text.trim();
    final String password = _passwordController.text;

    // Validasi input kosong
    if (npm.isEmpty) {
      setState(() => _errorMessage = 'NPM tidak boleh kosong.');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(npm)) {
      setState(() => _errorMessage = 'NPM hanya boleh berisi angka.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password tidak boleh kosong.');
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final List<UserAccount> users = await _api.fetchUsers();

      if (!mounted) return;

      if (!users.any(
        (UserAccount user) =>
            user.npm.isNotEmpty && user.passwordSha1.isNotEmpty,
      )) {
        setState(() {
          _errorMessage =
              'Data akun API belum memiliki NPM dan hash password. '
              'Periksa field NPM/userid dan Password/pass_sha1 pada endpoint demo.';
          _isLoggingIn = false;
        });
        return;
      }

      // Hitung SHA-1 dari password input
      final String inputHash = _api.sha1Hex(password);

      // Cari user yang NPM dan hash password cocok
      UserAccount? matched;
      for (final UserAccount u in users) {
        if (u.npm == npm && u.matchesPassword(password, inputHash)) {
          matched = u;
          break;
        }
      }

      if (matched == null) {
        setState(() {
          _errorMessage = 'NPM atau password salah.';
          _isLoggingIn = false;
        });
        return;
      }

      // Login berhasil
      final bool disabled = MediaQuery.of(context).disableAnimations;
      if (!disabled) {
        setState(() => _isExiting = true);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: disabled
              ? Duration.zero
              : const Duration(milliseconds: 700),
          pageBuilder: (_, _, _) => WelcomeScreen(user: matched!),
          transitionsBuilder:
              (
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
                    scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                    child: child,
                  ),
                );
              },
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final String msg = e.toString();
      setState(() {
        _isLoggingIn = false;
        if (msg.contains('SocketException') ||
            msg.contains('TimeoutException') ||
            msg.contains('HandshakeException')) {
          _errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        } else if (msg.contains('FormatException') || msg.contains('JSON')) {
          _errorMessage = 'Data dari server tidak valid. Coba lagi.';
        } else if (msg.contains('HttpException')) {
          _errorMessage = 'Server mengembalikan error. Coba lagi nanti.';
        } else {
          _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: AnimatedOpacity(
        opacity: _isExiting ? 0 : 1,
        duration: disabled ? Duration.zero : const Duration(milliseconds: 300),
        child: AnimatedSlide(
          offset: _isExiting ? const Offset(0, -0.15) : Offset.zero,
          duration: disabled
              ? Duration.zero
              : const Duration(milliseconds: 300),
          child: _buildContent(disabled),
        ),
      ),
    );
  }

  Widget _buildContent(bool disabled) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.hero,
                transform: GradientRotation(165 * math.pi / 180),
              ),
            ),
          ),
        ),
        _buildBlob(
          const Color(0xFF8B5CF6),
          150,
          0.35,
          phase: 0,
          top: -30,
          left: -40,
        ),
        _buildBlob(
          const Color(0xFF2DD4BF),
          110,
          0.28,
          phase: 1,
          top: 30,
          right: -30,
        ),
        _buildBlob(
          const Color(0xFFFF9A6B),
          90,
          0.30,
          phase: 2,
          top: 210,
          left: 120,
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: <Widget>[
                  Expanded(child: Center(child: _buildLogo(disabled))),
                  SizedBox(
                    height: constraints.maxHeight * 0.62,
                    child: _buildSheet(disabled),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlob(
    Color color,
    double size,
    double opacity, {
    required int phase,
    double? top,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _decor,
          builder: (BuildContext context, _) {
            final bool d = MediaQuery.of(context).disableAnimations;
            final double t = d ? 0 : (_decor.value + phase * 0.333) % 1.0;
            return Transform.translate(
              offset: Offset(16 * t, 12 * t),
              child: Transform.scale(
                scale: 1 + 0.1 * t,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        color.withValues(alpha: opacity),
                        color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(bool disabled) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_logo, _float]),
      builder: (BuildContext context, _) {
        final double scale = disabled
            ? 1
            : Curves.elasticOut.transform(_logo.value);
        final double opacity = disabled ? 1 : _logo.value;
        final double floatY = disabled ? 0 : -8 * _float.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 40,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'BAS',
                    style: AppText.loginTitle.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Boash Application System',
                    style: AppText.body.copyWith(
                      color: AppColors.headerSubtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheet(bool disabled) {
    return AnimatedBuilder(
      animation: _sheet,
      builder: (BuildContext context, Widget? child) {
        final double t = disabled
            ? 1
            : Curves.easeOutCubic.transform(_sheet.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 60 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.loginSheet),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Selamat datang kembali', style: AppText.sheetTitle),
              const SizedBox(height: 4),
              Text(
                'Masuk dengan NPM dan password akun demo.',
                style: AppText.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _AuthField(
                controller: _npmController,
                icon: Icons.badge_outlined,
                hint: 'NPM (misal: 12523030)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _AuthField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Password (misal: 123456)',
                obscure: true,
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dot.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: AppColors.dot,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppText.body.copyWith(
                            color: AppColors.dot,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _buildLoginButton(),
              const SizedBox(height: 14),
              // Informasi akun demo & tombol autofill cepat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.key_outlined,
                              size: 15,
                              color: AppColors.navy,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Akun Demo Pengujian',
                              style: AppText.listTitle.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _npmController.text = '12523030';
                              _passwordController.text = '123456';
                              _errorMessage = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Gunakan Akun Demo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NPM: 12523030 (Sofi Putri Rahayu)\nPassword: 123456 (atau admin / testpass / 12523030)',
                      style: AppText.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⚠ SHA-1 + MockAPI publik bukan autentikasi aman untuk produksi.',
                      style: AppText.caption.copyWith(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 16,
                    color: AppColors.navy,
                  ),
                  label: const Text(
                    'Buka Aplikasi QR Attendance (Pertemuan 6)',
                    style: TextStyle(fontSize: 12, color: AppColors.navy),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => const HomePage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _loginPressed = true),
      onTapUp: (_) => setState(() => _loginPressed = false),
      onTapCancel: () => setState(() => _loginPressed = false),
      onTap: _isLoggingIn ? null : _login,
      child: AnimatedScale(
        scale: _loginPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: 52,
          padding: const EdgeInsets.only(left: 20, right: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isLoggingIn
                  ? <Color>[
                      AppColors.navy.withValues(alpha: 0.7),
                      AppColors.royal.withValues(alpha: 0.7),
                    ]
                  : const <Color>[AppColors.navy, AppColors.royal],
            ),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _isLoggingIn ? 'Memeriksa...' : 'Masuk',
                      style: AppText.cardTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Lanjut ke Student App',
                      style: AppText.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _isLoggingIn
                    ? const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.navy,
                            backgroundColor: AppColors.border,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.navy,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _focused ? AppColors.card : AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? AppColors.navy : AppColors.border,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? const <BoxShadow>[
                BoxShadow(color: AppColors.focusRing, spreadRadius: 4),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          Icon(widget.icon, size: 20, color: AppColors.navy),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscure && !_showPassword,
              cursorColor: AppColors.navy,
              keyboardType: widget.keyboardType,
              style: AppText.body.copyWith(color: AppColors.navy),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: AppText.body.copyWith(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (widget.obscure)
            GestureDetector(
              onTap: () => setState(() => _showPassword = !_showPassword),
              child: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}
