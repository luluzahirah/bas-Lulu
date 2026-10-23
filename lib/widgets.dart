import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Pembungkus animasi masuk bertahap: naik 20 px + fade in.
class Staggered extends StatefulWidget {
  const Staggered({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<Staggered> createState() => _StaggeredState();
}

class _StaggeredState extends State<Staggered>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Teks angka yang menghitung naik dari 0 ke nilai akhir.
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 0,
    this.suffix = '',
  });

  final double value;
  final TextStyle style;
  final int decimals;
  final String suffix;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final double t = disabled
            ? 1
            : Curves.easeOutCubic.transform(_controller.value);
        final double shown = widget.value * t;
        return Text(
          '${shown.toStringAsFixed(widget.decimals)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// Bar yang tumbuh dari 0 ke target, tunda 500 ms.
class GrowBar extends StatefulWidget {
  const GrowBar({super.key, required this.target});

  final double target;

  @override
  State<GrowBar> createState() => _GrowBarState();
}

class _GrowBarState extends State<GrowBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final double t = disabled
            ? 1
            : Curves.easeOutCubic.transform(_controller.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 5,
            color: AppColors.navy.withValues(alpha: 0.12),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (widget.target * t).clamp(0.0, 1.0),
              child: const ColoredBox(color: AppColors.navy),
            ),
          ),
        );
      },
    );
  }
}

/// Tombol bulat putih berisi icon navy.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.dot = false,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final bool dot;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: AppColors.navy),
    );

    if (dot) {
      button = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          button,
          const Positioned(top: 6, right: 6, child: _PingDot()),
        ],
      );
    }

    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Tooltip(message: tooltip ?? '', child: button),
      ),
    );
  }
}

class _PingDot extends StatefulWidget {
  const _PingDot();

  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const _Dot(size: 8);
    }
    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) {
              final double t = _controller.value;
              return Container(
                width: 8 + 12 * t,
                height: 8 + 12 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dot.withValues(alpha: (1 - t) * 0.5),
                ),
              );
            },
          ),
          const _Dot(size: 8),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dot,
      ),
    );
  }
}

/// Lingkaran putih dengan panah. Bergeser 3 px saat hover/tekan.
class ArrowCircle extends StatefulWidget {
  const ArrowCircle({
    super.key,
    this.size = 42,
    this.background = AppColors.card,
    this.iconColor = AppColors.navy,
    this.onPressed,
    this.tooltip,
  });

  final double size;
  final Color background;
  final Color iconColor;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  State<ArrowCircle> createState() => _ArrowCircleState();
}

class _ArrowCircleState extends State<ArrowCircle> {
  bool _active = false;

  void _setActive(bool value) {
    if (_active != value) setState(() => _active = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setActive(true),
        onExit: (_) => _setActive(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setActive(true),
          onTapUp: (_) => _setActive(false),
          onTapCancel: () => _setActive(false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_active ? 3 : 0, 0, 0),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward,
              size: widget.size * 0.45,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Header gelap bergradasi dengan bulatan dekoratif melayang.
class DarkHeader extends StatefulWidget {
  const DarkHeader({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.decorations = AppColors.headerDecor,
  });

  final String? title;
  final String? subtitle;
  final Widget? child;
  final List<Color> decorations;

  @override
  State<DarkHeader> createState() => _DarkHeaderState();
}

class _DarkHeaderState extends State<DarkHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _decor(
    int i,
    Color color, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
  }) {
    final double opacity = 0.25 + (i % 3) * 0.05;
    final double phase = i * 0.35;
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          final bool disabled = MediaQuery.of(context).disableAnimations;
          final double t = disabled ? 0 : (_controller.value + phase) % 1.0;
          return Transform.translate(
            offset: Offset(16 * t, 12 * t),
            child: Transform.scale(
              scale: 1 + 0.1 * t,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: opacity),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = widget.decorations;
    if (colors.isEmpty) colors = AppColors.headerDecor;

    final List<Widget> circles = <Widget>[
      _decor(0, colors[0], top: -40, left: -30, size: 150),
      if (colors.length > 1)
        _decor(1, colors[1], top: 8, right: -34, size: 120),
      if (colors.length > 2)
        _decor(2, colors[2], bottom: -46, right: 60, size: 90),
    ];

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.navy, AppColors.navy2],
            transform: GradientRotation(165 * math.pi / 180),
          ),
        ),
        child: Stack(
          children: <Widget>[
            ...circles,
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 46),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: AppText.headerTitle.copyWith(color: Colors.white),
                    ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: AppText.headerTitle.copyWith(
                        color: AppColors.periwinkle,
                      ),
                    ),
                  if (widget.title != null && widget.child != null)
                    const SizedBox(height: 16),
                  if (widget.child != null) widget.child!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kolom pencarian berbentuk pill (tampilan saja).
class PillSearch extends StatelessWidget {
  const PillSearch({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 16, right: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, size: 20, color: AppColors.navy),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          ),
          Semantics(
            button: true,
            label: 'Filter',
            child: const Tooltip(
              message: 'Filter',
              child: SizedBox(
                width: 36,
                height: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tune, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Konten di bawah header: latar bg, sudut atas membulat, ditarik naik 26 px.
class SheetBody extends StatelessWidget {
  const SheetBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 20, 18, 0),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -26),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheetTop),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Widget pembungkus yang mengecil saat ditekan.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.scale = 0.97,
    this.onTap,
  });

  final Widget child;
  final double scale;
  final VoidCallback? onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Baris putih dengan tile pastel di kiri.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.leading,
    required this.body,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final Widget body;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.listRow),
        ),
        child: Row(
          children: <Widget>[
            leading,
            const SizedBox(width: 12),
            Expanded(child: body),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Tile persegi berlatar pastel dengan icon navy.
Widget pastelTile(
  IconData icon,
  int index, {
  double size = 48,
  double radius = 16,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.pastelAt(index),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Icon(icon, size: size * 0.5, color: AppColors.navy),
  );
}

/// Kartu gradasi untuk grid Info.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final List<Color> colors;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(AppRadius.gradientCard),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -22,
              right: -22,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.13),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              title,
                              style: AppText.cardTitle.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ArrowCircle(
                        size: 34,
                        background: Colors.white,
                        iconColor: AppColors.navy,
                        tooltip: title,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol utama bergradasi navy → royal dengan panah/spinner.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.title,
    this.subtitle,
    this.busy = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool busy;
  final VoidCallback? onTap;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.busy ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 22, right: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.navy, AppColors.royal],
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
                      widget.title,
                      style: AppText.cardTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
              _trailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailing() {
    if (widget.busy) {
      return Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.navy,
              backgroundColor: AppColors.border,
            ),
          ),
        ),
      );
    }
    return const ArrowCircle(size: 42);
  }
}
