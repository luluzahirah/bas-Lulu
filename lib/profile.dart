import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'pages/auth_page.dart';
import 'theme.dart';
import 'widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          DarkHeader(
            decorations: const <Color>[Color(0xFF2DD4BF), Color(0xFFFF9A6B)],
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  const _ProfileAvatar(),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    style: AppText.name.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    user.prodi,
                    style: AppText.body.copyWith(
                      color: AppColors.headerSubtitle,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                    leading: pastelTile(Icons.badge_outlined, 0),
                    body: _rowText('NPM', user.npm),
                  ),
                ),
                const SizedBox(height: 10),
                Staggered(
                  index: 2,
                  child: ListRow(
                    leading: pastelTile(Icons.menu_book_outlined, 2),
                    body: _rowText('Program Studi', user.prodi),
                  ),
                ),
                const SizedBox(height: 10),
                Staggered(
                  index: 3,
                  child: ListRow(
                    leading: pastelTile(Icons.account_balance_outlined, 3),
                    body: _rowText('Fakultas', user.fakultas),
                  ),
                ),
                if (user.email != null && user.email!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Staggered(
                    index: 4,
                    child: ListRow(
                      leading: pastelTile(Icons.mail_outline, 4),
                      body: _rowText('Email', user.email!),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Staggered(index: 5, child: _LogoutButton(user: user)),
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
          Expanded(
            child: _stat('Semester', user.semester.toDouble(), decimals: 0),
          ),
          Expanded(child: _stat('IPK', user.ipk, decimals: 2)),
          Expanded(child: _stat('SKS', user.sks.toDouble(), decimals: 0)),
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

/// Tombol logout dengan konfirmasi dialog.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.user});

  final UserAccount user;

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar'),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun ${user.name}?',
          style: AppText.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dot),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Hapus semua route dan kembali ke halaman login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF0),
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.dot.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.logout_outlined, size: 20, color: AppColors.dot),
            const SizedBox(width: 10),
            Text(
              'Keluar dari akun',
              style: AppText.cardTitle.copyWith(color: AppColors.dot),
            ),
          ],
        ),
      ),
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
    final double scale = disabled
        ? 1
        : Curves.elasticOut.transform(_enter.value);

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
