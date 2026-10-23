import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'theme.dart';
import 'welcome.dart';
import 'widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _exiting = false;

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
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _logo.forward();
    _float.repeat(reverse: true);
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _sheet.forward();
    });
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    _logo.dispose();
    _float.dispose();
    _sheet.dispose();
    _decor.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loading) return;
    final bool disabled = MediaQuery.of(context).disableAnimations;
    if (!disabled) {
      setState(() => _loading = true);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _exiting = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }
    _goToHome(disabled);
  }

  void _goToHome(bool disabled) {
    // Login.dart adalah halaman lama (legacy). Gunakan auth_page.dart untuk
    // autentikasi nyata via API. Di sini diteruskan dummy user agar kompilasi
    // tetap valid.
    const UserAccount dummyUser = UserAccount(
      npm: '0000000000',
      passwordSha1: '',
      name: 'Mahasiswa',
      prodi: 'Teknologi Rekayasa Multimedia',
      fakultas: 'Teknik',
      semester: 1,
      ipk: 0,
      sks: 0,
    );
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: disabled
            ? Duration.zero
            : const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) => const WelcomeScreen(user: dummyUser),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondary,
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
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _exiting ? 0 : 1,
        duration: disabled ? Duration.zero : const Duration(milliseconds: 300),
        child: AnimatedSlide(
          offset: _exiting ? const Offset(0, -0.15) : Offset.zero,
          duration: disabled
              ? Duration.zero
              : const Duration(milliseconds: 300),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
        _blob(const Color(0xFF8B5CF6), 150, 0.35, 0, top: -30, left: -40),
        _blob(const Color(0xFF2DD4BF), 110, 0.28, 1, top: 30, right: -30),
        _blob(const Color(0xFFFF9A6B), 90, 0.30, 2, top: 210, left: 120),
        Column(
          children: <Widget>[
            Expanded(child: Center(child: _buildLogo())),
            _buildSheet(),
          ],
        ),
      ],
    );
  }

  Widget _blob(
    Color color,
    double size,
    double opacity,
    int phase, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _decor,
        builder: (BuildContext context, _) {
          final bool disabled = MediaQuery.of(context).disableAnimations;
          final double t = disabled ? 0 : (_decor.value + phase * 0.333) % 1.0;
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
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_logo, _float]),
      builder: (BuildContext context, _) {
        final bool disabled = MediaQuery.of(context).disableAnimations;
        final double scale = disabled
            ? 1
            : Curves.elasticOut.transform(_logo.value);
        final double fade = disabled ? 1 : _logo.value;
        final double floatY = disabled ? 0 : -8 * _float.value;
        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 42,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 16),
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

  Widget _buildSheet() {
    return AnimatedBuilder(
      animation: _sheet,
      builder: (BuildContext context, Widget? child) {
        final bool disabled = MediaQuery.of(context).disableAnimations;
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
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.loginSheet),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Selamat datang kembali', style: AppText.sheetTitle),
            const SizedBox(height: 4),
            Text(
              'Masuk dengan NIM dan password kampus.',
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _LoginField(
              controller: _nimController,
              icon: Icons.person_outline,
              hint: '2024010001',
            ),
            const SizedBox(height: 14),
            _LoginField(
              controller: _passwordController,
              icon: Icons.lock_outline,
              hint: 'Password',
              obscure: true,
            ),
            const SizedBox(height: 22),
            GradientButton(
              title: 'Login',
              subtitle: 'Lanjut ke Student App',
              busy: _loading,
              onTap: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginField extends StatefulWidget {
  const _LoginField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
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
              focusNode: _focus,
              obscureText: widget.obscure,
              cursorColor: AppColors.navy,
              style: AppText.body.copyWith(color: AppColors.navy),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: AppText.body.copyWith(color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
