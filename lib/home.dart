import 'package:flutter/material.dart';

import 'theme.dart';
import 'welcome.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<(IconData, String)> _quick = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.tune, 'Settings'),
    (Icons.notifications_none, 'Notifications'),
    (Icons.person_outline, 'Profile'),
    (Icons.mail_outline, 'Email'),
    (Icons.phone_outlined, 'Phone'),
    (Icons.photo_camera_outlined, 'Camera'),
    (Icons.location_on_outlined, 'Map'),
    (Icons.shopping_cart_outlined, 'Cart'),
    (Icons.favorite_border, 'Favorite'),
    (Icons.music_note_outlined, 'Music'),
    (Icons.help_outline, 'Help'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 104),
      children: <Widget>[
        Staggered(index: 0, child: _buildTopBar(context)),
        const SizedBox(height: AppRadius.cardGap),
        Staggered(index: 1, child: _buildNextClass()),
        const SizedBox(height: AppRadius.cardGap),
        Staggered(index: 2, child: _buildSummary()),
        const SizedBox(height: AppRadius.cardGap),
        Staggered(index: 3, child: _buildQuickAccess(context)),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 6),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[AppColors.navy, Color(0xFF4F7BFF)],
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Selamat pagi,',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                ),
                Text('Lulu Zahirah', style: AppText.nameSmall),
              ],
            ),
          ),
          RoundIconButton(
            icon: Icons.notifications_none,
            dot: true,
            tooltip: 'Notifikasi',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNextClass() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppRadius.pagePadding),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.navy, AppColors.royal],
          ),
          borderRadius: BorderRadius.circular(AppRadius.bigCard),
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: <Widget>[
            const Positioned(
              right: -18,
              top: -14,
              child: _FloatIllustration(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Kelas berikutnya',
                  style: AppText.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  '08',
                  style: AppText.bigNumber.copyWith(color: Colors.white),
                ),
                Text(
                  'Okt 2026, Kamis',
                  style: AppText.caption.copyWith(color: Colors.white),
                ),
                Text(
                  '10.30 WIB, Pemrograman Mobile',
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppRadius.pagePadding),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.overview,
          ),
          borderRadius: BorderRadius.circular(AppRadius.bigCard),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text('Ringkasan akademik', style: AppText.listTitle)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Semester 5', style: AppText.caption),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryBox(
                    label: 'IPK',
                    value: 3.8,
                    target: 0.95,
                    decimals: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryBox(label: 'SKS', value: 96, target: 0.67),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryBox(
                    label: 'Hadir',
                    value: 92,
                    target: 0.92,
                    suffix: '%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppRadius.pagePadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.bigCard),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Akses cepat', style: AppText.listTitle),
            const SizedBox(height: 14),
            Column(
              children: <Widget>[
                for (int row = 0; row < 3; row++) ...<Widget>[
                  if (row > 0) const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      for (int col = 0; col < 4; col++)
                        Expanded(
                          child: _QuickMenu(
                            index: row * 4 + col,
                            icon: _quick[row * 4 + col].$1,
                            label: _quick[row * 4 + col].$2,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.target,
    this.decimals = 0,
    this.suffix = '',
  });

  final String label;
  final double value;
  final double target;
  final int decimals;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppText.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          CountUp(
            value: value,
            decimals: decimals,
            suffix: suffix,
            style: AppText.nameSmall.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          GrowBar(target: target),
        ],
      ),
    );
  }
}

class _QuickMenu extends StatefulWidget {
  const _QuickMenu({
    required this.index,
    required this.icon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final String label;

  @override
  State<_QuickMenu> createState() => _QuickMenuState();
}

class _QuickMenuState extends State<_QuickMenu> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool active = _hover || _pressed;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => ToastScope.of(context).showToast('${widget.label} dibuka'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSlide(
              offset: Offset(0, active ? -4 / 56 : 0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedRotation(
                turns: active ? -6 / 360 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: _pressed ? 0.9 : 1,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.navy
                          : AppColors.pastelAt(widget.index),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 26,
                      color: active ? Colors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatIllustration extends StatefulWidget {
  const _FloatIllustration();

  @override
  State<_FloatIllustration> createState() => _FloatIllustrationState();
}

class _FloatIllustrationState extends State<_FloatIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return _build(0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) => _build(-9 * _controller.value),
    );
  }

  Widget _build(double dy) {
    return Transform.translate(
      offset: Offset(0, dy),
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.5,
                ),
              ),
            ),
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.5,
                ),
              ),
            ),
            Icon(
              Icons.school_outlined,
              size: 58,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ],
        ),
      ),
    );
  }
}
