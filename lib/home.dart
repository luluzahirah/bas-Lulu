import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'theme.dart';
import 'welcome.dart';
import 'widgets.dart';

// ─── Model data tugas demo ────────────────────────────────────────────────────

class TugasItem {
  const TugasItem({
    required this.nama,
    required this.mataKuliah,
    required this.tenggat,
    required this.statusLabel,
    required this.overdue,
  });

  final String nama;
  final String mataKuliah;
  final DateTime tenggat;
  final String statusLabel;
  final bool overdue;
}

/// Data tugas demo — ditandai eksplisit sebagai demo.
final List<TugasItem> _demoTugas = <TugasItem>[
  TugasItem(
    nama: 'Laporan Proyek Mobile App',
    mataKuliah: 'Pemrograman Mobile',
    tenggat: DateTime.now().add(const Duration(days: 2)),
    statusLabel: 'Belum dikumpulkan',
    overdue: false,
  ),
  TugasItem(
    nama: 'Wireframe & Prototype UI',
    mataKuliah: 'Desain UI/UX',
    tenggat: DateTime.now().add(const Duration(days: 5)),
    statusLabel: 'Sedang dikerjakan',
    overdue: false,
  ),
  TugasItem(
    nama: 'ER Diagram & DDL',
    mataKuliah: 'Basis Data',
    tenggat: DateTime.now().add(const Duration(days: 9)),
    statusLabel: 'Belum dikerjakan',
    overdue: false,
  ),
];

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final UserAccount user;

  // Akses cepat: (icon, label, akademikIndex)
  // akademikIndex: 0=Materi,1=Tugas,2=Nilai,3=Presensi,4=KTM,5=KRS
  static const List<(IconData, String, int)> _quick = <(IconData, String, int)>[
    (Icons.book_outlined, 'Materi', 0),
    (Icons.assignment_outlined, 'Tugas', 1),
    (Icons.bar_chart_outlined, 'Nilai', 2),
    (Icons.fact_check_outlined, 'Presensi', 3),
    (Icons.credit_card_outlined, 'KTM', 4),
    (Icons.list_alt_outlined, 'KRS', 5),
  ];

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    final List<JadwalItem> jadwalHariIni = getJadwalHariIni();
    // Sort tugas by tenggat
    final List<TugasItem> sortedTugas = List<TugasItem>.from(_demoTugas)
      ..sort((TugasItem a, TugasItem b) => a.tenggat.compareTo(b.tenggat));

    return ListView(
      padding: const EdgeInsets.only(bottom: 104),
      children: <Widget>[
        Staggered(index: 0, child: _buildTopBar(context)),
        const SizedBox(height: 14),
        Staggered(index: 1, child: _buildJadwalHariIni(context, jadwalHariIni)),
        const SizedBox(height: 14),
        Staggered(index: 2, child: _buildTugasTerdekat(sortedTugas)),
        const SizedBox(height: 14),
        Staggered(index: 3, child: _buildQuickAccess(context)),
        const SizedBox(height: 14),
        Staggered(index: 4, child: _buildPengumumanRingkas(context)),
      ],
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.hero,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF4F7BFF), AppColors.periwinkle],
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
                  _greeting(),
                  style: AppText.body.copyWith(color: AppColors.headerSubtitle),
                ),
                Text(
                  user.name,
                  style: AppText.nameSmall.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          RoundIconButton(
            icon: Icons.notifications_none,
            dot: false,
            tooltip: 'Notifikasi',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ── Jadwal Hari Ini ─────────────────────────────────────────────────────────

  Widget _buildJadwalHariIni(BuildContext context, List<JadwalItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppRadius.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionHeader(
            'Jadwal Hari Ini',
            Icons.calendar_today_outlined,
            onTap: () => NavScope.of(context).goToTab(1),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            _emptyCard(
              Icons.event_available_outlined,
              'Tidak ada kuliah hari ini',
              'Selamat menikmati waktu luangmu 🎉',
            )
          else
            Column(
              children: <Widget>[
                for (int i = 0; i < items.take(3).length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _JadwalHariIniCard(item: items[i]),
                  ),
                if (items.length > 3)
                  _moreButton(
                    '${items.length - 3} jadwal lainnya',
                    () => NavScope.of(context).goToTab(1),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Tugas Terdekat ──────────────────────────────────────────────────────────

  Widget _buildTugasTerdekat(List<TugasItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppRadius.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionHeader('Tugas Terdekat', Icons.assignment_outlined),
          const SizedBox(height: 10),
          if (items.isEmpty)
            _emptyCard(
              Icons.check_circle_outline,
              'Tidak ada tugas',
              'Semua tugas telah selesai!',
            )
          else
            Column(
              children: <Widget>[
                for (int i = 0; i < items.take(3).length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TugasCard(item: items[i]),
                  ),
              ],
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.info_outline,
                  size: 13,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo — Data tugas bukan tugas resmi akademik.',
                    style: AppText.caption.copyWith(
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Akses Cepat ─────────────────────────────────────────────────────────────

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
            _sectionHeader('Akses Cepat', Icons.grid_view_rounded),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                for (int i = 0; i < _quick.length; i++)
                  Expanded(
                    child: _QuickMenu(
                      index: i,
                      icon: _quick[i].$1,
                      label: _quick[i].$2,
                      onTap: () =>
                          NavScope.of(context).goToAkademik(_quick[i].$3),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Ringkasan Pengumuman ─────────────────────────────────────────────────────

  Widget _buildPengumumanRingkas(BuildContext context) {
    final PengumumanItem latest = demoPengumuman.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppRadius.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionHeader(
            'Pengumuman Terbaru',
            Icons.campaign_outlined,
            onTap: () => NavScope.of(context).goToTab(3),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => NavScope.of(context).goToTab(3),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: latest.gradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(latest.icon, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          latest.title,
                          style: AppText.listTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          latest.summary,
                          style: AppText.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, {VoidCallback? onTap}) {
    return Row(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.pastelAt(0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.navy),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppText.listTitle)),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Lihat semua',
              style: AppText.caption.copyWith(color: AppColors.royal),
            ),
          ),
      ],
    );
  }

  Widget _emptyCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 36, color: AppColors.muted),
          const SizedBox(height: 8),
          Text(title, style: AppText.listTitle.copyWith(color: AppColors.navy)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _moreButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.pastelAt(0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.body.copyWith(color: AppColors.navy),
          ),
        ),
      ),
    );
  }
}

// ─── Jadwal Hari Ini Card ─────────────────────────────────────────────────────

class _JadwalHariIniCard extends StatelessWidget {
  const _JadwalHariIniCard({required this.item});

  final JadwalItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.g1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.mataKuliah,
                  style: AppText.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.jamMulai} – ${item.jamSelesai}',
                      style: AppText.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.room_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.ruang,
                        style: AppText.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tugas Card ───────────────────────────────────────────────────────────────

class _TugasCard extends StatelessWidget {
  const _TugasCard({required this.item});

  final TugasItem item;

  String _formatTenggat(DateTime dt) {
    final Duration diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Terlambat';
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Besok';
    return '${diff.inDays} hari lagi';
  }

  Color _tenggatColor() {
    final Duration diff = item.tenggat.difference(DateTime.now());
    if (diff.isNegative || diff.inDays <= 1) return AppColors.dot;
    if (diff.inDays <= 3) return const Color(0xFFF59E0B);
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.pastelAt(1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 20,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.nama,
                  style: AppText.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.mataKuliah,
                  style: AppText.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                _formatTenggat(item.tenggat),
                style: AppText.caption.copyWith(
                  color: _tenggatColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.statusLabel,
                style: AppText.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Menu ───────────────────────────────────────────────────────────────

class _QuickMenu extends StatefulWidget {
  const _QuickMenu({
    required this.index,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickMenu> createState() => _QuickMenuState();
}

class _QuickMenuState extends State<_QuickMenu> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool active = _pressed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedScale(
            scale: _pressed ? 0.9 : 1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.navy
                    : AppColors.pastelAt(widget.index),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: active ? Colors.white : AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
