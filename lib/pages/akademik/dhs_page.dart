import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets.dart';
import 'dhs_kuliah_page.dart';
import 'transkrip_page.dart';

// ─── Data sub-menu DHS ────────────────────────────────────────────────────────

class _DhsMenu {
  const _DhsMenu({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final void Function(BuildContext) onTap;
}

// ─── DhsPage ──────────────────────────────────────────────────────────────────

/// Halaman DHS (Daftar Hasil Studi) sebagai pusat akses laporan akademik.
class DhsPage extends StatelessWidget {
  const DhsPage({super.key, this.npm});

  /// NPM mahasiswa untuk diteruskan ke halaman DHS Kuliah.
  final String? npm;

  List<_DhsMenu> _menus(BuildContext context) => <_DhsMenu>[
    _DhsMenu(
      icon: Icons.school_rounded,
      title: 'DHS Kuliah',
      subtitle: 'Nilai per mata kuliah (API)',
      colors: const <Color>[Color(0xFF0F766E), Color(0xFF34D399)],
      onTap: (BuildContext ctx) {
        final String targetNpm = npm ?? '12523030';
        Navigator.of(ctx).push(
          MaterialPageRoute<void>(
            builder: (_) => DhsKuliahPage(npm: targetNpm),
          ),
        );
      },
    ),
    _DhsMenu(
      icon: Icons.description_outlined,
      title: 'Transkrip Nilai',
      subtitle: 'Riwayat nilai per semester',
      colors: AppColors.g1,
      onTap: (BuildContext ctx) => Navigator.of(
        ctx,
      ).push(MaterialPageRoute<void>(builder: (_) => const TranskripPage())),
    ),
    _DhsMenu(
      icon: Icons.trending_up_rounded,
      title: 'Rekap IPK',
      subtitle: 'Grafik perkembangan IPK',
      colors: AppColors.g2,
      onTap: (BuildContext ctx) => _showComingSoon(ctx, 'Rekap IPK'),
    ),
    _DhsMenu(
      icon: Icons.playlist_add_check_outlined,
      title: 'Nilai Per Semester',
      subtitle: 'Detail nilai tiap semester',
      colors: AppColors.g3,
      onTap: (BuildContext ctx) => _showComingSoon(ctx, 'Nilai Per Semester'),
    ),
    _DhsMenu(
      icon: Icons.military_tech_outlined,
      title: 'Prestasi Akademik',
      subtitle: 'Penghargaan dan pencapaian',
      colors: AppColors.g4,
      onTap: (BuildContext ctx) => _showComingSoon(ctx, 'Prestasi Akademik'),
    ),
    _DhsMenu(
      icon: Icons.school_outlined,
      title: 'Status Kelulusan',
      subtitle: 'Syarat kelulusan & SKS',
      colors: const <Color>[Color(0xFF7C3AED), Color(0xFFB27BFF)],
      onTap: (BuildContext ctx) => _showComingSoon(ctx, 'Status Kelulusan'),
    ),
    _DhsMenu(
      icon: Icons.download_outlined,
      title: 'Unduh Transkrip',
      subtitle: 'Ekspor dalam format PDF',
      colors: const <Color>[Color(0xFF0E7490), Color(0xFF38BDF8)],
      onTap: (BuildContext ctx) => _showDownloadInfo(ctx),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<_DhsMenu> menus = _menus(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[_buildHeader(context), _buildBody(context, menus)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.hero,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            // Dekorasi lingkaran
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Tombol back + judul baris
                  Row(
                    children: <Widget>[
                      Semantics(
                        button: true,
                        label: 'Kembali',
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'DHS',
                            style: AppText.headerTitle.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Daftar Hasil Studi',
                            style: AppText.caption.copyWith(
                              color: AppColors.periwinkle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Kartu ringkasan singkat
                  _buildQuickStats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: <Widget>[
          _QuickStat(
            icon: Icons.star_outline_rounded,
            label: 'IPK',
            value: '—',
          ),
          _divider(),
          _QuickStat(
            icon: Icons.library_books_outlined,
            label: 'Total SKS',
            value: '—',
          ),
          _divider(),
          _QuickStat(
            icon: Icons.calendar_today_outlined,
            label: 'Semester',
            value: '—',
          ),
          _divider(),
          _QuickStat(
            icon: Icons.badge_outlined,
            label: 'NPM',
            value: npm != null
                ? npm!.length > 6
                      ? '...${npm!.substring(npm!.length - 5)}'
                      : npm!
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildBody(BuildContext context, List<_DhsMenu> menus) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheetTop),
          topRight: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      transform: Matrix4.translationValues(0, -AppRadius.sheetTop, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Staggered(
              index: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Layanan DHS', style: AppText.listTitle),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Text(
                      'DEMO',
                      style: AppText.caption.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Staggered(
              index: 1,
              child: Text(
                'Pilih layanan untuk melihat hasil studi Anda.',
                style: AppText.body.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            // Grid 2 kolom
            for (
              int row = 0;
              row < (menus.length / 2).ceil();
              row++
            ) ...<Widget>[
              if (row > 0) const SizedBox(height: 14),
              Staggered(
                index: row + 2,
                child: Row(
                  children: <Widget>[
                    for (int col = 0; col < 2; col++) ...<Widget>[
                      if (col > 0) const SizedBox(width: 14),
                      Expanded(
                        child: (row * 2 + col) < menus.length
                            ? _DhsCard(
                                menu: menus[row * 2 + col],
                                index: row * 2 + col,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Info banner
            Staggered(index: 5, child: _buildInfoBanner()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.overview,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.navy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Data Akademik Resmi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Untuk transkrip resmi dan berlegalisir, '
                  'hubungi bagian akademik kampus.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String fitur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$fitur — Segera hadir!',
          style: AppText.body.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 80),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDownloadInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.download_outlined,
              color: AppColors.navy,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text('Unduh Transkrip', style: AppText.listTitle),
          ],
        ),
        content: Text(
          'Fitur unduh transkrip dalam format PDF belum tersedia pada '
          'versi demo ini.\n\nUntuk mendapatkan transkrip resmi dan '
          'berlegalisir, silakan kunjungi bagian akademik kampus secara langsung.',
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Mengerti',
              style: AppText.body.copyWith(color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QuickStat ────────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppText.cardTitle.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── DhsCard ──────────────────────────────────────────────────────────────────

class _DhsCard extends StatefulWidget {
  const _DhsCard({required this.menu, required this.index});

  final _DhsMenu menu;
  final int index;

  @override
  State<_DhsCard> createState() => _DhsCardState();
}

class _DhsCardState extends State<_DhsCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.menu.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => widget.menu.onTap(context),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.menu.colors,
              ),
              borderRadius: BorderRadius.circular(AppRadius.gradientCard),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.menu.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                // Dekorasi lingkaran
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
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
                        child: Icon(
                          widget.menu.icon,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.menu.title,
                        style: AppText.cardTitle.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.menu.subtitle,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
