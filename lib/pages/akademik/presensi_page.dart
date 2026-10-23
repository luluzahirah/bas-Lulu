import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets.dart';

class _PresensiSummary {
  const _PresensiSummary({
    required this.mataKuliah,
    required this.hadir,
    required this.izin,
    required this.alpha,
    required this.total,
  });

  final String mataKuliah;
  final int hadir;
  final int izin;
  final int alpha;
  final int total;

  double get persentase => total == 0 ? 0 : hadir / total;
}

const List<_PresensiSummary> _demoPresensi = <_PresensiSummary>[
  _PresensiSummary(
    mataKuliah: 'Pemrograman Mobile',
    hadir: 12,
    izin: 1,
    alpha: 0,
    total: 13,
  ),
  _PresensiSummary(
    mataKuliah: 'Desain UI/UX',
    hadir: 10,
    izin: 2,
    alpha: 1,
    total: 13,
  ),
  _PresensiSummary(
    mataKuliah: 'Rekayasa Perangkat Lunak',
    hadir: 11,
    izin: 0,
    alpha: 0,
    total: 11,
  ),
  _PresensiSummary(
    mataKuliah: 'Basis Data',
    hadir: 9,
    izin: 1,
    alpha: 2,
    total: 12,
  ),
  _PresensiSummary(
    mataKuliah: 'Jaringan Komputer',
    hadir: 10,
    izin: 1,
    alpha: 1,
    total: 12,
  ),
];

class PresensiPage extends StatelessWidget {
  const PresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Presensi',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: <Widget>[
          _buildDemoNotice(),
          const SizedBox(height: 16),
          Text('Rekap Kehadiran', style: AppText.listTitle),
          const SizedBox(height: 12),
          for (int i = 0; i < _demoPresensi.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PresensiCard(item: _demoPresensi[i], index: i),
            ),
        ],
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Demo — Data presensi bukan data resmi.',
                  style: AppText.body.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fitur absensi aktif belum terhubung ke backend. '
                  'Jangan anggap data ini sebagai kehadiran resmi.',
                  style: AppText.caption.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresensiCard extends StatelessWidget {
  const _PresensiCard({required this.item, required this.index});

  final _PresensiSummary item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double pct = item.persentase;
    final Color statusColor = pct >= 0.85
        ? const Color(0xFF22C55E)
        : pct >= 0.75
        ? const Color(0xFFF59E0B)
        : AppColors.dot;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              pastelTile(Icons.fact_check_outlined, index),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.mataKuliah,
                  style: AppText.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: AppText.body.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              color: statusColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _statBadge(
                Icons.check_circle_outline,
                'Hadir',
                item.hadir,
                const Color(0xFF22C55E),
              ),
              const SizedBox(width: 8),
              _statBadge(
                Icons.info_outline,
                'Izin',
                item.izin,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _statBadge(
                Icons.cancel_outlined,
                'Alpha',
                item.alpha,
                AppColors.dot,
              ),
              const Spacer(),
              Text(
                '${item.hadir + item.izin + item.alpha}/${item.total} pertemuan',
                style: AppText.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(IconData icon, String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text('$count $label', style: AppText.caption.copyWith(color: color)),
      ],
    );
  }
}
