import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

class PengumumanItem {
  const PengumumanItem({
    required this.id,
    required this.category,
    required this.date,
    required this.title,
    required this.summary,
    required this.body,
    required this.gradient,
    required this.icon,
  });

  final String id;
  final String category;
  final String date;
  final String title;
  final String summary;
  final String body;
  final List<Color> gradient;
  final IconData icon;
}

const List<PengumumanItem> demoPengumuman = <PengumumanItem>[
  PengumumanItem(
    id: '1',
    category: 'Akademik',
    date: '23 Okt 2026',
    title: 'Jadwal Ujian Akhir Semester',
    summary: 'Cek ruang dan jam ujianmu.',
    body:
        'Demo — Ujian Akhir Semester (UAS) Semester 5 akan dilaksanakan pada minggu ke-3 November 2026. '
        'Jadwal detail ruang dan waktu ujian akan diumumkan melalui portal akademik resmi. '
        'Pastikan kamu memenuhi syarat kehadiran minimal 75% untuk dapat mengikuti ujian.\n\n'
        'Catatan: Pengumuman ini adalah demo dan bukan jadwal resmi institusi.',
    gradient: AppColors.g1,
    icon: Icons.menu_book_outlined,
  ),
  PengumumanItem(
    id: '2',
    category: 'Kegiatan',
    date: '22 Okt 2026',
    title: 'Seminar Teknologi Nasional',
    summary: 'Pendaftaran dibuka hingga Jumat.',
    body:
        'Demo — Seminar Teknologi Nasional akan diselenggarakan di Auditorium kampus. '
        'Acara ini menghadirkan pembicara dari industri teknologi dan perguruan tinggi ternama. '
        'Pendaftaran gratis untuk mahasiswa aktif.\n\n'
        'Catatan: Pengumuman ini adalah demo dan bukan acara resmi institusi.',
    gradient: AppColors.g2,
    icon: Icons.workspace_premium_outlined,
  ),
  PengumumanItem(
    id: '3',
    category: 'Info',
    date: '20 Okt 2026',
    title: 'Pembayaran UKT Semester Genap',
    summary: 'Bayar sebelum tenggat agar KRS aktif.',
    body:
        'Demo — Pembayaran Uang Kuliah Tunggal (UKT) untuk semester genap '
        '2026/2027 telah dibuka. Pastikan melakukan pembayaran sebelum tenggat '
        'untuk mengaktifkan akun KRS kamu.\n\n'
        'Catatan: Pengumuman ini adalah demo dan bukan informasi resmi pembayaran.',
    gradient: AppColors.g3,
    icon: Icons.info_outline,
  ),
  PengumumanItem(
    id: '4',
    category: 'Akademik',
    date: '15 Okt 2026',
    title: 'Pengisian KRS Semester Genap',
    summary: 'Isi KRS melalui portal mahasiswa.',
    body:
        'Demo — Periode pengisian Kartu Rencana Studi (KRS) untuk semester genap '
        '2026/2027 akan segera dibuka. Konsultasikan dengan dosen pembimbing akademik '
        'kamu sebelum mengisi KRS.\n\n'
        'Catatan: Pengumuman ini adalah demo.',
    gradient: AppColors.g1,
    icon: Icons.assignment_outlined,
  ),
  PengumumanItem(
    id: '5',
    category: 'Kegiatan',
    date: '10 Okt 2026',
    title: 'Lomba Hackathon Kampus',
    summary: 'Bentuk tim dan daftar hari ini.',
    body:
        'Demo — Hackathon Kampus 2026 akan segera diselenggarakan. '
        'Bentuk tim beranggotakan 3–5 orang dan daftarkan timmu sekarang. '
        'Tersedia hadiah menarik untuk 3 tim terbaik.\n\n'
        'Catatan: Pengumuman ini adalah demo.',
    gradient: AppColors.g4,
    icon: Icons.emoji_events_outlined,
  ),
];

class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen> {
  static const List<String> _filters = <String>[
    'Semua',
    'Akademik',
    'Kegiatan',
    'Info',
  ];

  String _filter = 'Semua';
  bool _isLoading = false;

  List<PengumumanItem> get _filtered {
    if (_filter == 'Semua') return demoPengumuman;
    return demoPengumuman
        .where((PengumumanItem e) => e.category == _filter)
        .toList();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  Color _tagColor(String category) {
    switch (category) {
      case 'Akademik':
        return AppColors.pastelAt(0);
      case 'Kegiatan':
        return AppColors.pastelAt(1);
      default:
        return AppColors.pastelAt(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.navy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            const DarkHeader(
              title: 'Pengumuman',
              subtitle: 'dari kampus',
              child: PillSearch(hint: 'Cari pengumuman...'),
            ),
            SheetBody(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFilters(),
                  const SizedBox(height: 14),
                  _buildDemoNotice(),
                  const SizedBox(height: 14),
                  if (_isLoading)
                    const _LoadingState()
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: KeyedSubtree(
                        key: ValueKey<String>(_filter),
                        child: _buildList(),
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

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String filter in _filters) ...<Widget>[
            if (filter != _filters.first) const SizedBox(width: 8),
            _Chip(
              label: filter,
              active: _filter == filter,
              onTap: () => setState(() => _filter = filter),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline, size: 13, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo — Pengumuman ini bukan informasi resmi kampus.',
              style: AppText.caption.copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final List<PengumumanItem> items = _filtered;
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return Column(
      children: <Widget>[
        for (int i = 0; i < items.length; i++)
          Staggered(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildRow(items[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(PengumumanItem item) {
    return ListRow(
      onTap: () => _openDetail(item),
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(item.icon, size: 28, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _tagColor(item.category),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.category, style: AppText.caption),
              ),
              const SizedBox(width: 8),
              Text(
                item.date,
                style: AppText.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.title, style: AppText.listTitle),
          Text(
            item.summary,
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.muted,
      ),
    );
  }

  void _openDetail(PengumumanItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PengumumanDetailPage(item: item)),
    );
  }
}

class PengumumanDetailPage extends StatelessWidget {
  const PengumumanDetailPage({super.key, required this.item});

  final PengumumanItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradient,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, size: 36, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pastelAt(0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.category, style: AppText.caption),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.date,
                        style: AppText.caption.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.title, style: AppText.name),
                  const SizedBox(height: 16),
                  Text(
                    item.body,
                    style: AppText.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.navy : AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppText.body.copyWith(
              color: active ? Colors.white : AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.pastelAt(0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 40,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 16),
          Text('Belum ada pengumuman', style: AppText.nameSmall),
          const SizedBox(height: 8),
          Text(
            'Tidak ada pengumuman dalam kategori ini.',
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
