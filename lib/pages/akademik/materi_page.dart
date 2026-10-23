import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets.dart';

class _MateriItem {
  const _MateriItem({
    required this.mataKuliah,
    required this.judul,
    required this.pertemuan,
    required this.tipe,
  });

  final String mataKuliah;
  final String judul;
  final int pertemuan;
  final String tipe; // PDF, Video, Link
}

const List<_MateriItem> _demoMateri = <_MateriItem>[
  _MateriItem(
    mataKuliah: 'Pemrograman Mobile',
    judul: 'Pengenalan Flutter & Dart',
    pertemuan: 1,
    tipe: 'PDF',
  ),
  _MateriItem(
    mataKuliah: 'Pemrograman Mobile',
    judul: 'Widget Dasar Flutter',
    pertemuan: 2,
    tipe: 'PDF',
  ),
  _MateriItem(
    mataKuliah: 'Pemrograman Mobile',
    judul: 'State Management',
    pertemuan: 3,
    tipe: 'Video',
  ),
  _MateriItem(
    mataKuliah: 'Desain UI/UX',
    judul: 'Prinsip Desain Visual',
    pertemuan: 1,
    tipe: 'PDF',
  ),
  _MateriItem(
    mataKuliah: 'Desain UI/UX',
    judul: 'Figma untuk Pemula',
    pertemuan: 2,
    tipe: 'Link',
  ),
  _MateriItem(
    mataKuliah: 'Basis Data',
    judul: 'Konsep Relasional',
    pertemuan: 1,
    tipe: 'PDF',
  ),
  _MateriItem(
    mataKuliah: 'Basis Data',
    judul: 'SQL Dasar',
    pertemuan: 2,
    tipe: 'PDF',
  ),
];

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  String _selectedMK = 'Semua';

  List<String> get _mataKuliahList {
    final Set<String> set = <String>{'Semua'};
    for (final _MateriItem m in _demoMateri) {
      set.add(m.mataKuliah);
    }
    return set.toList();
  }

  List<_MateriItem> get _filtered {
    if (_selectedMK == 'Semua') return _demoMateri;
    return _demoMateri
        .where((_MateriItem m) => m.mataKuliah == _selectedMK)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Materi',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final String mk in _mataKuliahList)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: mk.length > 16 ? '${mk.substring(0, 14)}…' : mk,
                        active: _selectedMK == mk,
                        onTap: () => setState(() => _selectedMK = mk),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              itemCount: _filtered.length,
              itemBuilder: (BuildContext context, int i) {
                final _MateriItem item = _filtered[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListRow(
                    leading: pastelTile(_typeIcon(item.tipe), i),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(item.judul, style: AppText.listTitle),
                        const SizedBox(height: 2),
                        Text(
                          '${item.mataKuliah}  •  Pertemuan ${item.pertemuan}',
                          style: AppText.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelAt(i),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.tipe,
                        style: AppText.caption.copyWith(fontSize: 10),
                      ),
                    ),
                    onTap: () => _showDemo(context, item.judul),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String tipe) {
    switch (tipe) {
      case 'Video':
        return Icons.play_circle_outline;
      case 'Link':
        return Icons.link;
      default:
        return Icons.picture_as_pdf_outlined;
    }
  }

  void _showDemo(BuildContext context, String judul) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Demo'),
        content: Text(
          '"$judul"\n\nFitur buka materi belum terhubung ke backend.',
          style: AppText.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.card : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppText.body.copyWith(
            color: active ? AppColors.navy : Colors.white,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
