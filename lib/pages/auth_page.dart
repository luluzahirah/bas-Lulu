import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../theme.dart';
import '../welcome.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.authApi});

  final AuthApi? authApi;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Map<String, dynamic>? _user;
  String? _message;
  bool _isLoadingUser = false;
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

  Map<String, dynamic>? get _loginDetails {
    final dynamic login = _user?['login'];
    return login is Map<String, dynamic> ? login : null;
  }

  @override
  void initState() {
    super.initState();
    _logo.forward();
    _float.repeat(reverse: true);
    _decor.repeat(reverse: true);
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _sheet.forward();
    });
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _logo.dispose();
    _float.dispose();
    _sheet.dispose();
    _decor.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoadingUser = true;
      _message = null;
    });

    try {
      final user = await (widget.authApi ?? AuthApi()).fetchRandomUser();
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _user = null;
        _message = 'Gagal memuat user: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (_isLoggingIn || _isLoadingUser) return;

    final login = _loginDetails;
    final dynamic username = login?['username'];
    final dynamic password = login?['password'];

    if (username is! String || password is! String) {
      setState(() {
        _message = 'User belum dimuat. Silakan coba lagi.';
      });
      return;
    }

    if (_usernameController.text == username &&
        _passwordController.text == password) {
      final bool disabled = MediaQuery.of(context).disableAnimations;
      setState(() => _isLoggingIn = true);
      if (!disabled) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        setState(() {
          _isLoggingIn = false;
          _isExiting = true;
        });
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: disabled
              ? Duration.zero
              : const Duration(milliseconds: 700),
          pageBuilder: (_, _, _) => const WelcomeScreen(),
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
      return;
    }

    setState(() {
      _message = 'Username atau password salah';
    });
  }

  String _credential(String key) {
    final dynamic value = _loginDetails?[key];
    return value is String ? value : '-';
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
                    height: constraints.maxHeight * 0.53,
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoadingUser || _isLoggingIn ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: Listener(
        onPointerDown: (_) => setState(() => _loginPressed = true),
        onPointerUp: (_) => setState(() => _loginPressed = false),
        onPointerCancel: (_) => setState(() => _loginPressed = false),
        child: AnimatedScale(
          scale: _loginPressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.navy, AppColors.royal],
              ),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Container(
              height: 56,
              padding: const EdgeInsets.only(left: 22, right: 7),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Login',
                          style: AppText.cardTitle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Lanjut ke Student App',
                          style: AppText.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoggingIn
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.navy,
                                backgroundColor: AppColors.border,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            size: 19,
                            color: AppColors.navy,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            final bool disabled = MediaQuery.of(context).disableAnimations;
            final double t = disabled
                ? 0
                : (_decor.value + phase * 0.333) % 1.0;
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
      child: SingleChildScrollView(
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
                'Masuk dengan username dan password dari user acak.',
                style: AppText.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _AuthField(
                controller: _usernameController,
                icon: Icons.person_outline,
                hint: 'Username',
              ),
              const SizedBox(height: 14),
              _AuthField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Password',
                obscure: true,
              ),
              if (_message != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: AppText.body.copyWith(
                    color: _user == null ? AppColors.dot : AppColors.navy,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _buildLoginButton(),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Akun untuk testing', style: AppText.listTitle),
                    const SizedBox(height: 4),
                    Text(
                      'Username: ${_credential('username')}',
                      style: AppText.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Password: ${_credential('password')}',
                      style: AppText.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoadingUser ? null : _loadUser,
                        child: Text(
                          _isLoadingUser ? 'Memuat...' : 'Ganti User Acak',
                          style: AppText.body.copyWith(color: AppColors.navy),
                        ),
                      ),
                    ),
                  ],
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
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _focused = _focusNode.hasFocus;
    });
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
              focusNode: _focusNode,
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
