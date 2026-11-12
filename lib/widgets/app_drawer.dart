import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../pages/akademik/khs_page.dart';
import '../pages/akademik/krs_page.dart';
import '../pages/akademik/pengajuan_studi_page.dart';
import '../pages/akademik/presensi_page.dart';
import '../pages/auth_page.dart';
import '../services/session_service.dart';
import '../theme.dart';
import '../welcome.dart';
import 'app_confirm_dialog.dart';

/// Komponen Sidebar (Drawer) navigasi aplikasi BAS.
/// Memuat menu utama: Beranda, KRS, Pengajuan Studi, KHS, Presensi, Profil, Logout.
/// Dilengkapi highlight menu aktif dan penutupan otomatis saat item dipilih.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.user,
    this.currentRoute = '',
  });

  final UserAccount? user;
  final String currentRoute; // '/', '/krs', '/pengajuan-studi', '/khs', '/presensi', '/profil'

  UserAccount get _activeUser {
    final SessionService session = SessionService.instance;
    return user ?? session.currentUser ?? AuthApi.defaultDemoUser;
  }

  void _navigateTo(BuildContext context, String route, WidgetBuilder builder) {
    Navigator.of(context).pop(); // Tutup drawer terlebih dahulu

    if (currentRoute == route) return; // Sudah di halaman ini

    if (route == '/' || route == 'beranda') {
      final NavScope? nav = NavScope.maybeOf(context);
      if (nav != null) {
        nav.goToTab(0);
      } else {
        Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
      }
      return;
    }

    if (currentRoute.isNotEmpty && Navigator.of(context).canPop()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: builder),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: builder),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserAccount activeUser = _activeUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.hero,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[Color(0xFF4F7BFF), AppColors.periwinkle],
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Smt ${activeUser.semester}',
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    activeUser.name,
                    style: AppText.nameSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NPM: ${activeUser.npm} • ${activeUser.prodi}',
                    style: AppText.caption.copyWith(
                      color: AppColors.headerSubtitle,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: <Widget>[
                  _DrawerTile(
                    icon: Icons.home_rounded,
                    title: 'Beranda',
                    subtitle: 'Halaman utama dashboard',
                    isActive: currentRoute == '/' || currentRoute == 'beranda',
                    onTap: () {
                      Navigator.of(context).pop();
                      final NavScope? nav = NavScope.maybeOf(context);
                      if (nav != null) {
                        nav.goToTab(0);
                      } else {
                        Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _DrawerTile(
                    icon: Icons.list_alt_rounded,
                    title: 'KRS',
                    subtitle: 'Kartu Rencana Studi (3 Tab)',
                    iconColor: const Color(0xFF0284C7),
                    isActive: currentRoute == '/krs',
                    onTap: () => _navigateTo(
                      context,
                      '/krs',
                      (_) => const KrsPage(),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Pengajuan Studi',
                    subtitle: 'Form & riwayat permohonan',
                    iconColor: const Color(0xFF7C3AED),
                    isActive: currentRoute == '/pengajuan-studi',
                    onTap: () => _navigateTo(
                      context,
                      '/pengajuan-studi',
                      (_) => const PengajuanStudiPage(),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.grade_rounded,
                    title: 'KHS',
                    subtitle: 'Kartu Hasil Studi & Nilai',
                    iconColor: const Color(0xFF0F766E),
                    isActive: currentRoute == '/khs',
                    onTap: () => _navigateTo(
                      context,
                      '/khs',
                      (_) => KhsPage(npm: activeUser.npm),
                    ),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _DrawerTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Presensi',
                    subtitle: 'Absensi QR perkuliahan',
                    iconColor: const Color(0xFFEA580C),
                    isActive: currentRoute == '/presensi',
                    onTap: () => _navigateTo(
                      context,
                      '/presensi',
                      (_) => const PresensiPage(),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.person_rounded,
                    title: 'Profil Mahasiswa',
                    subtitle: 'Informasi akun & identitas',
                    isActive: currentRoute == '/profil',
                    onTap: () {
                      Navigator.of(context).pop();
                      final NavScope? nav = NavScope.maybeOf(context);
                      if (nav != null) {
                        nav.goToTab(4);
                      } else {
                        Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Logout Footer (Secara visual dipisahkan di bagian bawah)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Keluar Akun',
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                onTap: () async {
                  final bool confirm = await AppConfirmDialog.show(
                    context,
                    title: 'Keluar Akun',
                    message: 'Apakah Anda yakin ingin keluar dari aplikasi BAS?',
                    confirmText: 'Keluar',
                    cancelText: 'Batal',
                    isDanger: true,
                    icon: Icons.logout_rounded,
                  );
                  if (confirm && context.mounted) {
                    SessionService.instance.clearSession();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuthPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.isActive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = iconColor ?? AppColors.royal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: AppColors.royal.withValues(alpha: 0.3), width: 1.2)
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.royal
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: AppText.body.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? AppColors.royal : AppColors.navy,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppText.caption.copyWith(
            color: isActive ? AppColors.royal.withValues(alpha: 0.8) : AppColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
        trailing: Icon(
          isActive ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
          size: 18,
          color: isActive ? AppColors.royal : const Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }
}
