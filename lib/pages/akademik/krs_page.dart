import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets.dart';

class _KrsItem {
  const _KrsItem({
    required this.kode,
    required this.mataKuliah,
    required this.sks,
    required this.kelas,
    required this.hari,
    required this.jam,
    required this.status,
  });

  final String kode;
  final String mataKuliah;
  final int sks;
  final String kelas;
  final String hari;
  final String jam;
  final String status; // 'Disetujui', 'Menunggu', 'Ditolak'
}

const List<_KrsItem> _demoKrs = <_KrsItem>[
  _KrsItem(
    kode: 'TRM-501',
    mataKuliah: 'Pemrograman Mobile',
    sks: 3,
    kelas: 'A',
    hari: 'Senin',
    jam: '08:00 – 10:30',
    status: 'Disetujui',
  ),
  _KrsItem(
    kode: 'TRM-502',
    mataKuliah: 'Desain UI/UX',
    sks: 3,
    kelas: 'A',
    hari: 'Selasa',
    jam: '13:00 – 15:30',
    status: 'Disetujui',
  ),
  _KrsItem(
    kode: 'TRM-503',
    mataKuliah: 'Rekayasa Perangkat Lunak',
    sks: 2,
    kelas: 'B',
    hari: 'Rabu',
    jam: '10:00 – 12:00',
    status: 'Disetujui',
  ),
  _KrsItem(
    kode: 'TRM-504',
    mataKuliah: 'Basis Data',
    sks: 3,
    kelas: 'A',
    hari: 'Selasa',
    jam: '13:00 – 15:30',
    status: 'Disetujui',
  ),
  _KrsItem(
    kode: 'TRM-505',
    mataKuliah: 'Jaringan Komputer',
    sks: 2,
    kelas: 'C',
    hari: 'Rabu',
    jam: '08:00 – 10:00',
    status: 'Menunggu',
  ),
];

class KrsPage extends StatelessWidget {
  const KrsPage({super.key});

  int get _totalSks => _demoKrs.fold(0, (int sum, _KrsItem k) => sum + k.sks);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'KRS',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 14),
          _buildDemoNotice(),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text('Mata Kuliah Semester 5', style: AppText.listTitle),
              const Spacer(),
              Text(
                '$_totalSks SKS',
                style: AppText.listTitle.copyWith(color: AppColors.royal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _demoKrs.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _KrsCard(item: _demoKrs[i], index: i),
            ),
          const SizedBox(height: 8),
          _buildStatusInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0E7490), Color(0xFF38BDF8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'KRS Semester 5',
                  style: AppText.nameSmall.copyWith(color: Colors.white),
                ),
                Text(
                  'Tahun Akademik 2025/2026',
                  style: AppText.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$_totalSks',
                style: AppText.name.copyWith(color: Colors.white),
              ),
              Text(
                'Total SKS',
                style: AppText.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo — KRS ini tidak tersimpan ke sistem akademik resmi. '
              'Jangan anggap sebagai pengajuan KRS yang valid.',
              style: AppText.caption.copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Keterangan Status', style: AppText.listTitle),
          const SizedBox(height: 10),
          _statusRow(
            Icons.check_circle_outline,
            'Disetujui',
            'Mata kuliah telah disetujui pembimbing akademik',
            const Color(0xFF22C55E),
          ),
          const SizedBox(height: 6),
          _statusRow(
            Icons.schedule_outlined,
            'Menunggu',
            'Menunggu persetujuan pembimbing akademik',
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 6),
          _statusRow(
            Icons.cancel_outlined,
            'Ditolak',
            'Mata kuliah tidak dapat diambil semester ini',
            AppColors.dot,
          ),
        ],
      ),
    );
  }

  Widget _statusRow(IconData icon, String label, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: AppText.body.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                desc,
                style: AppText.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KrsCard extends StatelessWidget {
  const _KrsCard({required this.item, required this.index});

  final _KrsItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(item.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          pastelTile(Icons.list_alt_outlined, index),
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
                Text(
                  '${item.kode} • Kelas ${item.kelas} • ${item.sks} SKS',
                  style: AppText.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.hari} – ${item.jam}',
                  style: AppText.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.status,
              style: AppText.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return const Color(0xFF22C55E);
      case 'Menunggu':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.dot;
    }
  }
}
