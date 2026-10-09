import 'package:flutter/material.dart';

import 'theme.dart';
import 'welcome.dart';
import 'widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          DarkHeader(
            decorations: const <Color>[
              Color(0xFF2DD4BF),
              Color(0xFFFF9A6B),
            ],
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  const _ProfileAvatar(),
                  const SizedBox(height: 14),
                  Text(
                    'Alina Putri',
                    style: AppText.name.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Mahasiswa aktif',
                    style: AppText.body
                        .copyWith(color: AppColors.headerSubtitle),
                  ),
                ],
              ),
            ),
          ),
          SheetBody(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
            child: Column(
              children: <Widget>[
                Staggered(index: 0, child: _buildStats()),
                const SizedBox(height: 14),
                Staggered(
                  index: 1,
                  child: ListRow(
                    leading: pastelTile(Icons.school_outlined, 1),
                    body: _rowText('NIM', '2024010001'),
                  ),
                ),
                const SizedBox(height: 10),
                Staggered(
                  index: 2,
                  child: ListRow(
                    leading: pastelTile(Icons.menu_book_outlined, 2),
                    body: _rowText('Program studi', 'Teknik Informatika'),
                  ),
                ),
                const SizedBox(height: 10),
                Staggered(
                  index: 3,
                  child: ListRow(
                    leading: pastelTile(Icons.mail_outline, 3),
                    body: _rowText('Email', 'nama@kampus.ac.id'),
                  ),
                ),
                const SizedBox(height: 20),
                Staggered(
                  index: 4,
                  child: GradientButton(
                    title: 'Ubah profil',
                    subtitle: 'Perbarui data diri',
                    onTap: () =>
                        ToastScope.of(context).showToast('Ubah profil dibuka'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: AppText.listTitle),
        Text(
          value,
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _stat('Semester', 5)),
          Expanded(child: _stat('IPK', 3.8, decimals: 1)),
          Expanded(child: _stat('SKS', 96)),
        ],
      ),
    );
  }

  Widget _stat(String label, double value, {int decimals = 0}) {
    return Column(
      children: <Widget>[
        CountUp(
          value: value,
          decimals: decimals,
          style: AppText.nameSmall.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar();

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ring.repeat(count: 2);
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = MediaQuery.of(context).disableAnimations;
    final double scale =
        disabled ? 1 : Curves.elasticOut.transform(_enter.value);

    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (!disabled)
            AnimatedBuilder(
              animation: _ring,
              builder: (BuildContext context, _) {
                final double t = _ring.value;
                return Opacity(
                  opacity: (1 - t) * 0.7,
                  child: Transform.scale(
                    scale: 1 + 0.5 * t,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.periwinkle,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          Transform.scale(
            scale: scale,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(color: AppColors.periwinkle, width: 4),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 46,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
