import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets.dart';

class _TugasItem {
  const _TugasItem({
    required this.judul,
    required this.mataKuliah,
    required this.tenggat,
    required this.status,
    required this.deskripsi,
  });

  final String judul;
  final String mataKuliah;
  final DateTime tenggat;
  final String status; // 'Belum', 'Dikerjakan', 'Dikumpulkan'
  final String deskripsi;
}

final List<_TugasItem> _demoTugas = <_TugasItem>[
  _TugasItem(
    judul: 'Implementasi Bottom Navigation',
    mataKuliah: 'Pemrograman Mobile',
    tenggat: DateTime.now().add(const Duration(days: 3)),
    status: 'Dikerjakan',
    deskripsi: 'Buat aplikasi Flutter dengan bottom navigation 5 tab.',
  ),
  _TugasItem(
    judul: 'Desain Wireframe Aplikasi',
    mataKuliah: 'Desain UI/UX',
    tenggat: DateTime.now().add(const Duration(days: 7)),
    status: 'Belum',
    deskripsi: 'Buat wireframe untuk aplikasi e-commerce menggunakan Figma.',
  ),
  _TugasItem(
    judul: 'Laporan ERD Database',
    mataKuliah: 'Basis Data',
    tenggat: DateTime.now().add(const Duration(days: 1)),
    status: 'Dikerjakan',
    deskripsi: 'Buat Entity Relationship Diagram untuk sistem perpustakaan.',
  ),
  _TugasItem(
    judul: 'Analisis Kebutuhan Sistem',
    mataKuliah: 'Rekayasa Perangkat Lunak',
    tenggat: DateTime.now().subtract(const Duration(days: 2)),
    status: 'Dikumpulkan',
    deskripsi: 'Buat dokumen analisis kebutuhan sistem informasi akademik.',
  ),
];

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Tugas',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        itemCount: _demoTugas.length,
        itemBuilder: (BuildContext context, int i) {
          final _TugasItem item = _demoTugas[i];
          final bool isOverdue =
              item.status != 'Dikumpulkan' &&
              item.tenggat.isBefore(DateTime.now());
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TugasCard(
              item: item,
              isOverdue: isOverdue,
              onTap: () => _showDetail(context, item),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, _TugasItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _TugasDetailPage(item: item)),
    );
  }
}

class _TugasCard extends StatelessWidget {
  const _TugasCard({
    required this.item,
    required this.isOverdue,
    required this.onTap,
  });

  final _TugasItem item;
  final bool isOverdue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(item.status, isOverdue);
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: isOverdue
              ? Border.all(color: AppColors.dot.withValues(alpha: 0.3))
              : null,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.judul, style: AppText.listTitle),
                  const SizedBox(height: 2),
                  Text(
                    item.mataKuliah,
                    style: AppText.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_outlined
                            : Icons.schedule_outlined,
                        size: 12,
                        color: isOverdue ? AppColors.dot : AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTenggat(item.tenggat, isOverdue),
                        style: AppText.caption.copyWith(
                          color: isOverdue ? AppColors.dot : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.status,
                style: AppText.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status, bool isOverdue) {
    if (isOverdue) return AppColors.dot;
    switch (status) {
      case 'Dikumpulkan':
        return const Color(0xFF22C55E);
      case 'Dikerjakan':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.muted;
    }
  }

  String _formatTenggat(DateTime tenggat, bool isOverdue) {
    final int diffDays = tenggat.difference(DateTime.now()).inDays;
    if (isOverdue) {
      return 'Tenggat lewat ${-diffDays} hari lalu';
    }
    if (diffDays == 0) return 'Tenggat hari ini';
    if (diffDays == 1) return 'Tenggat besok';
    return 'Tenggat $diffDays hari lagi';
  }
}

class _TugasDetailPage extends StatelessWidget {
  const _TugasDetailPage({required this.item});

  final _TugasItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Detail Tugas',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.judul, style: AppText.name),
                  const SizedBox(height: 6),
                  Text(
                    item.mataKuliah,
                    style: AppText.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  _row(
                    Icons.schedule_outlined,
                    'Tenggat',
                    _formatDate(item.tenggat),
                  ),
                  const SizedBox(height: 10),
                  _row(Icons.flag_outlined, 'Status', item.status),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Deskripsi', style: AppText.listTitle),
                  const SizedBox(height: 10),
                  Text(
                    item.deskripsi,
                    style: AppText.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fitur pengumpulan tugas adalah Demo dan belum terhubung ke backend.',
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
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.navy),
        const SizedBox(width: 8),
        Text(label, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(
          value,
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
