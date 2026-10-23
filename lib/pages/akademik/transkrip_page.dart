import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets.dart';

// ─── Model Data Transkrip ──────────────────────────────────────────────────────

class _MataKuliahItem {
  const _MataKuliahItem({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.nilai,
    required this.huruf,
    required this.bobot,
  });

  final String kode;
  final String nama;
  final int sks;
  final double nilai;
  final String huruf;
  final double bobot;
}

class _SemesterData {
  const _SemesterData({
    required this.semester,
    required this.tahunAjaran,
    required this.mataKuliah,
  });

  final int semester;
  final String tahunAjaran;
  final List<_MataKuliahItem> mataKuliah;

  int get totalSks =>
      mataKuliah.fold(0, (int sum, _MataKuliahItem m) => sum + m.sks);

  double get ips {
    double totalBobot = 0;
    int totalSks = 0;
    for (final _MataKuliahItem m in mataKuliah) {
      totalBobot += m.bobot * m.sks;
      totalSks += m.sks;
    }
    return totalSks == 0 ? 0 : totalBobot / totalSks;
  }
}

// ─── Data Demo Transkrip ───────────────────────────────────────────────────────

const List<_SemesterData> _demoTranskrip = <_SemesterData>[
  _SemesterData(
    semester: 1,
    tahunAjaran: '2022/2023 Ganjil',
    mataKuliah: <_MataKuliahItem>[
      _MataKuliahItem(
        kode: 'MKU-101',
        nama: 'Kalkulus 1',
        sks: 3,
        nilai: 80,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-101',
        nama: 'Dasar Pemrograman',
        sks: 3,
        nilai: 88,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'MKU-102',
        nama: 'Bahasa Indonesia',
        sks: 2,
        nilai: 85,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-102',
        nama: 'Pengantar Teknologi Informasi',
        sks: 2,
        nilai: 78,
        huruf: 'B+',
        bobot: 3.5,
      ),
      _MataKuliahItem(
        kode: 'MKU-103',
        nama: 'Pendidikan Kewarganegaraan',
        sks: 2,
        nilai: 82,
        huruf: 'A',
        bobot: 4.0,
      ),
    ],
  ),
  _SemesterData(
    semester: 2,
    tahunAjaran: '2022/2023 Genap',
    mataKuliah: <_MataKuliahItem>[
      _MataKuliahItem(
        kode: 'TIF-201',
        nama: 'Algoritma dan Struktur Data',
        sks: 3,
        nilai: 85,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'MKU-201',
        nama: 'Kalkulus 2',
        sks: 3,
        nilai: 75,
        huruf: 'B',
        bobot: 3.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-202',
        nama: 'Sistem Digital',
        sks: 3,
        nilai: 79,
        huruf: 'B+',
        bobot: 3.5,
      ),
      _MataKuliahItem(
        kode: 'MKU-202',
        nama: 'Bahasa Inggris',
        sks: 2,
        nilai: 80,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-203',
        nama: 'Matematika Diskrit',
        sks: 3,
        nilai: 77,
        huruf: 'B+',
        bobot: 3.5,
      ),
    ],
  ),
  _SemesterData(
    semester: 3,
    tahunAjaran: '2023/2024 Ganjil',
    mataKuliah: <_MataKuliahItem>[
      _MataKuliahItem(
        kode: 'TIF-301',
        nama: 'Basis Data',
        sks: 3,
        nilai: 91,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-302',
        nama: 'Pemrograman Berorientasi Objek',
        sks: 3,
        nilai: 87,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-303',
        nama: 'Jaringan Komputer',
        sks: 3,
        nilai: 74,
        huruf: 'B',
        bobot: 3.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-304',
        nama: 'Statistika dan Probabilitas',
        sks: 2,
        nilai: 79,
        huruf: 'B+',
        bobot: 3.5,
      ),
      _MataKuliahItem(
        kode: 'MKU-301',
        nama: 'Etika Profesi',
        sks: 2,
        nilai: 86,
        huruf: 'A',
        bobot: 4.0,
      ),
    ],
  ),
  _SemesterData(
    semester: 4,
    tahunAjaran: '2023/2024 Genap',
    mataKuliah: <_MataKuliahItem>[
      _MataKuliahItem(
        kode: 'TIF-401',
        nama: 'Rekayasa Perangkat Lunak',
        sks: 3,
        nilai: 84,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-402',
        nama: 'Sistem Operasi',
        sks: 3,
        nilai: 78,
        huruf: 'B+',
        bobot: 3.5,
      ),
      _MataKuliahItem(
        kode: 'TIF-403',
        nama: 'Kecerdasan Buatan',
        sks: 3,
        nilai: 82,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-404',
        nama: 'Interaksi Manusia Komputer',
        sks: 2,
        nilai: 90,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TIF-405',
        nama: 'Pemrograman Web',
        sks: 3,
        nilai: 81,
        huruf: 'A',
        bobot: 4.0,
      ),
    ],
  ),
  _SemesterData(
    semester: 5,
    tahunAjaran: '2024/2025 Ganjil',
    mataKuliah: <_MataKuliahItem>[
      _MataKuliahItem(
        kode: 'TRM-501',
        nama: 'Pemrograman Mobile',
        sks: 3,
        nilai: 88,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TRM-502',
        nama: 'Desain UI/UX',
        sks: 3,
        nilai: 82,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TRM-503',
        nama: 'Rekayasa Perangkat Lunak',
        sks: 2,
        nilai: 78,
        huruf: 'B+',
        bobot: 3.5,
      ),
      _MataKuliahItem(
        kode: 'TRM-504',
        nama: 'Basis Data',
        sks: 3,
        nilai: 91,
        huruf: 'A',
        bobot: 4.0,
      ),
      _MataKuliahItem(
        kode: 'TRM-505',
        nama: 'Jaringan Komputer',
        sks: 2,
        nilai: 75,
        huruf: 'B',
        bobot: 3.0,
      ),
    ],
  ),
];

// ─── Helper ───────────────────────────────────────────────────────────────────

double _hitungIpk(List<_SemesterData> semesterList) {
  double totalBobot = 0;
  int totalSks = 0;
  for (final _SemesterData s in semesterList) {
    for (final _MataKuliahItem m in s.mataKuliah) {
      totalBobot += m.bobot * m.sks;
      totalSks += m.sks;
    }
  }
  return totalSks == 0 ? 0 : totalBobot / totalSks;
}

int _hitungTotalSks(List<_SemesterData> semesterList) {
  return semesterList.fold(0, (int sum, _SemesterData s) => sum + s.totalSks);
}

Color _hurufColor(String huruf) {
  if (huruf.startsWith('A')) return const Color(0xFF22C55E);
  if (huruf.startsWith('B')) return const Color(0xFF3B82F6);
  if (huruf.startsWith('C')) return const Color(0xFFF59E0B);
  return AppColors.dot;
}

// ─── TranskripPage ─────────────────────────────────────────────────────────────

class TranskripPage extends StatefulWidget {
  const TranskripPage({super.key});

  @override
  State<TranskripPage> createState() => _TranskripPageState();
}

class _TranskripPageState extends State<TranskripPage> {
  // Semester yang sedang di-expand
  int? _expandedSemester;

  double get _ipkKumulatif => _hitungIpk(_demoTranskrip);
  int get _totalSksKumulatif => _hitungTotalSks(_demoTranskrip);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Transkrip Nilai',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            label: 'Cetak transkrip',
            child: IconButton(
              tooltip: 'Cetak / Unduh',
              icon: const Icon(Icons.print_outlined, size: 22),
              onPressed: () => _showPrintDialog(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: <Widget>[
          // Kartu ringkasan IPK kumulatif
          Staggered(index: 0, child: _buildSummaryCard()),
          const SizedBox(height: 16),
          // Banner demo
          Staggered(index: 1, child: _buildDemoBanner()),
          const SizedBox(height: 16),
          // Label
          Staggered(
            index: 2,
            child: Text('Riwayat Per Semester', style: AppText.listTitle),
          ),
          const SizedBox(height: 12),
          // Kartu tiap semester
          for (int i = 0; i < _demoTranskrip.length; i++) ...<Widget>[
            Staggered(
              index: i + 3,
              child: _SemesterCard(
                data: _demoTranskrip[i],
                isExpanded: _expandedSemester == _demoTranskrip[i].semester,
                onToggle: () => setState(() {
                  _expandedSemester =
                      _expandedSemester == _demoTranskrip[i].semester
                      ? null
                      : _demoTranskrip[i].semester;
                }),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.g1,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1E4FD8).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          // Dekorasi lingkaran
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Transkrip Akademik',
                        style: AppText.listTitle.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Alina Putri — 2024010001',
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  _SummaryBox(
                    label: 'IPK Kumulatif',
                    value: _ipkKumulatif.toStringAsFixed(2),
                    icon: Icons.star_outline_rounded,
                  ),
                  const SizedBox(width: 12),
                  _SummaryBox(
                    label: 'Total SKS',
                    value: _totalSksKumulatif.toString(),
                    icon: Icons.library_books_outlined,
                  ),
                  const SizedBox(width: 12),
                  _SummaryBox(
                    label: 'Semester',
                    value: '${_demoTranskrip.length}',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar IPK
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Pencapaian IPK',
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Text(
                        '${(_ipkKumulatif / 4.0 * 100).toStringAsFixed(0)}%',
                        style: AppText.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _ipkKumulatif / 4.0,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline, size: 15, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠ Demo — Transkrip ini bukan dokumen resmi. '
              'Data hanya untuk keperluan demonstrasi tampilan.',
              style: AppText.caption.copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrintDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cetak / Unduh', style: AppText.listTitle),
        content: Text(
          'Fitur cetak transkrip belum tersedia pada versi demo ini. '
          'Silakan hubungi bagian akademik kampus untuk mendapatkan transkrip resmi.',
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Tutup',
              style: AppText.body.copyWith(color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget SummaryBox ─────────────────────────────────────────────────────────

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppText.cardTitle.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget SemesterCard (accordion) ──────────────────────────────────────────

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.data,
    required this.isExpanded,
    required this.onToggle,
  });

  final _SemesterData data;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: <Widget>[
          // Header semester
          Semantics(
            button: true,
            label:
                'Semester ${data.semester}, ketuk untuk ${isExpanded ? 'tutup' : 'buka'}',
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: <Widget>[
                    // Nomor semester
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.pastelAt(data.semester - 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${data.semester}',
                          style: AppText.cardTitle.copyWith(
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Semester ${data.semester}',
                            style: AppText.listTitle,
                          ),
                          Text(
                            data.tahunAjaran,
                            style: AppText.caption.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chip IPS dan SKS
                    _ChipInfo(label: 'IPS', value: data.ips.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _ChipInfo(label: 'SKS', value: data.totalSks.toString()),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.muted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tabel detail (expanded)
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: <Widget>[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                        indent: 14,
                        endIndent: 14,
                      ),
                      _buildTable(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      child: Column(
        children: <Widget>[
          // Header tabel
          _TableHeader(),
          const SizedBox(height: 6),
          // Baris tiap mata kuliah
          for (int i = 0; i < data.mataKuliah.length; i++) ...<Widget>[
            _TableRow(item: data.mataKuliah[i], index: i),
            if (i < data.mataKuliah.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
          ],
          const SizedBox(height: 10),
          // Baris total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'TOTAL SEMESTER ${data.semester}',
                    style: AppText.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    data.totalSks.toString(),
                    style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    'IPS: ${data.ips.toStringAsFixed(2)}',
                    style: AppText.caption.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
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

// ─── Widget Tabel ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Mata Kuliah',
              style: AppText.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              'SKS',
              style: AppText.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              'Nilai',
              style: AppText.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'Huruf',
              style: AppText.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.item, required this.index});

  final _MataKuliahItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color huruf = _hurufColor(item.huruf);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.nama,
                  style: AppText.caption.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.kode,
                  style: AppText.caption.copyWith(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              item.sks.toString(),
              style: AppText.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              item.nilai.toInt().toString(),
              style: AppText.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: huruf.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.huruf,
                  style: AppText.caption.copyWith(
                    color: huruf,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget ChipInfo ──────────────────────────────────────────────────────────

class _ChipInfo extends StatelessWidget {
  const _ChipInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$label ',
              style: AppText.caption.copyWith(
                color: AppColors.muted,
                fontSize: 10,
              ),
            ),
            TextSpan(
              text: value,
              style: AppText.caption.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
