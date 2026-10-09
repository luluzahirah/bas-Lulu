import 'package:flutter/material.dart';

import 'theme.dart';
import 'welcome.dart';
import 'widgets.dart';

class _NewsItem {
  const _NewsItem({
    required this.category,
    required this.date,
    required this.title,
    required this.summary,
    required this.gradient,
    required this.icon,
  });

  final String category;
  final String date;
  final String title;
  final String summary;
  final List<Color> gradient;
  final IconData icon;
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const List<String> _filters = <String>[
    'Semua',
    'Akademik',
    'Kegiatan',
    'Info',
  ];

  static const List<_NewsItem> _items = <_NewsItem>[
    _NewsItem(
      category: 'Akademik',
      date: '09 Okt 2026',
      title: 'Jadwal ujian semester',
      summary: 'Cek ruang dan jam ujianmu.',
      gradient: AppColors.g1,
      icon: Icons.menu_book_outlined,
    ),
    _NewsItem(
      category: 'Kegiatan',
      date: '08 Okt 2026',
      title: 'Seminar teknologi',
      summary: 'Pendaftaran dibuka sampai Jumat.',
      gradient: AppColors.g2,
      icon: Icons.workspace_premium_outlined,
    ),
    _NewsItem(
      category: 'Info',
      date: '07 Okt 2026',
      title: 'Pembayaran UKT dibuka',
      summary: 'Bayar sebelum tenggat agar KRS aktif.',
      gradient: AppColors.g3,
      icon: Icons.info_outline,
    ),
    _NewsItem(
      category: 'Akademik',
      date: '05 Okt 2026',
      title: 'Pengisian KRS dimulai',
      summary: 'Isi KRS lewat portal mahasiswa.',
      gradient: AppColors.g1,
      icon: Icons.menu_book_outlined,
    ),
    _NewsItem(
      category: 'Kegiatan',
      date: '03 Okt 2026',
      title: 'Lomba coding kampus',
      summary: 'Bentuk tim dan daftar hari ini.',
      gradient: AppColors.g4,
      icon: Icons.workspace_premium_outlined,
    ),
  ];

  String _filter = 'Semua';

  List<_NewsItem> get _filtered {
    if (_filter == 'Semua') return _items;
    return _items.where((_NewsItem e) => e.category == _filter).toList();
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
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const DarkHeader(
            title: 'Berita terbaru',
            subtitle: 'dari kampus',
            child: PillSearch(hint: 'Cari berita...'),
          ),
          SheetBody(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
            child: Column(
              children: <Widget>[
                _buildFilters(),
                const SizedBox(height: 14),
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

  Widget _buildList() {
    final List<_NewsItem> items = _filtered;
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

  Widget _buildRow(_NewsItem item) {
    return ListRow(
      onTap: () => ToastScope.of(context).showToast('${item.title} dibuka'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

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
