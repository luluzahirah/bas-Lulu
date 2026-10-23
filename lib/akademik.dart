import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'theme.dart';
import 'widgets.dart';
import 'pages/akademik/materi_page.dart';
import 'pages/akademik/tugas_page.dart';
import 'pages/akademik/nilai_page.dart';
import 'pages/akademik/presensi_page.dart';
import 'pages/akademik/ktm_page.dart';
import 'pages/akademik/krs_page.dart';
import 'pages/akademik/dhs_page.dart';

class AkademikScreen extends StatelessWidget {
  const AkademikScreen({super.key, this.initialIndex, this.user});

  /// Jika tidak null, langsung buka menu di indeks tersebut.
  final int? initialIndex;

  /// Data user untuk diteruskan ke halaman yang membutuhkan (KTM).
  final UserAccount? user;

  static const List<_MenuData> _menus = <_MenuData>[
    _MenuData(
      icon: Icons.book_outlined,
      label: 'Materi',
      subtitle: 'Bahan kuliah',
      colors: AppColors.g1,
    ),
    _MenuData(
      icon: Icons.assignment_outlined,
      label: 'Tugas',
      subtitle: 'Pengumpulan',
      colors: AppColors.g2,
    ),
    _MenuData(
      icon: Icons.bar_chart_outlined,
      label: 'Nilai',
      subtitle: 'Transkrip',
      colors: AppColors.g3,
    ),
    _MenuData(
      icon: Icons.fact_check_outlined,
      label: 'Presensi',
      subtitle: 'Kehadiran',
      colors: AppColors.g4,
    ),
    _MenuData(
      icon: Icons.credit_card_outlined,
      label: 'KTM',
      subtitle: 'Kartu mahasiswa',
      colors: <Color>[Color(0xFF7C3AED), Color(0xFFB27BFF)],
    ),
    _MenuData(
      icon: Icons.list_alt_outlined,
      label: 'KRS',
      subtitle: 'Pilih mata kuliah',
      colors: <Color>[Color(0xFF0E7490), Color(0xFF38BDF8)],
    ),
    _MenuData(
      icon: Icons.workspace_premium_outlined,
      label: 'DHS',
      subtitle: 'Hasil studi',
      colors: <Color>[Color(0xFF0F766E), Color(0xFF34D399)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Jika initialIndex diberikan, langsung push halaman tujuan setelah build
    if (initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _openMenu(context, initialIndex!);
        }
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const DarkHeader(
            title: 'Akademik',
            subtitle: 'layanan kampusmu',
            decorations: <Color>[
              Color(0xFF1E4FD8),
              Color(0xFF7C3AED),
              Color(0xFF0E7490),
            ],
          ),
          SheetBody(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Fitur akademik', style: AppText.listTitle),
                const SizedBox(height: 4),
                Text(
                  'Akses layanan akademik di bawah ini.',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _buildGrid(context),
                const SizedBox(height: 20),
                _buildDemoNotice(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final int rowCount = (_menus.length / 2).ceil();
    return Column(
      children: <Widget>[
        for (int row = 0; row < rowCount; row++) ...<Widget>[
          if (row > 0) const SizedBox(height: 14),
          Staggered(
            index: row,
            child: Row(
              children: <Widget>[
                for (int col = 0; col < 2; col++) ...<Widget>[
                  if (col > 0) const SizedBox(width: 14),
                  Expanded(
                    child: (row * 2 + col) < _menus.length
                        ? _AkademikCard(
                            data: _menus[row * 2 + col],
                            index: row * 2 + col,
                            onTap: () => _openMenu(context, row * 2 + col),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Semua fitur akademik di atas adalah tampilan demo. '
              'Data yang ditampilkan bukan data resmi dan belum terhubung ke backend.',
              style: AppText.caption.copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  void _openMenu(BuildContext context, int index) {
    final Widget page;
    switch (index) {
      case 0:
        page = const MateriPage();
      case 1:
        page = const TugasPage();
      case 2:
        page = NilaiPage(npm: user?.npm);
      case 3:
        page = const PresensiPage();
      case 4:
        // Teruskan user ke KtmPage agar KTM menampilkan data sesungguhnya
        page = KtmPage(user: user);
      case 5:
        page = const KrsPage();
      case 6:
        page = DhsPage(npm: user?.npm);
      default:
        return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _MenuData {
  const _MenuData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> colors;
}

class _AkademikCard extends StatefulWidget {
  const _AkademikCard({
    required this.data,
    required this.index,
    required this.onTap,
  });

  final _MenuData data;
  final int index;
  final VoidCallback onTap;

  @override
  State<_AkademikCard> createState() => _AkademikCardState();
}

class _AkademikCardState extends State<_AkademikCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.data.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
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
                colors: widget.data.colors,
              ),
              borderRadius: BorderRadius.circular(AppRadius.gradientCard),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.data.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
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
                          widget.data.icon,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.data.label,
                        style: AppText.cardTitle.copyWith(color: Colors.white),
                      ),
                      Text(
                        widget.data.subtitle,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
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
