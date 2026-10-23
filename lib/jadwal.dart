import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

/// Model data jadwal mata kuliah.
class JadwalItem {
  const JadwalItem({
    required this.mataKuliah,
    required this.kode,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruang,
    required this.dosen,
    required this.hari,
    required this.sks,
  });

  final String mataKuliah;
  final String kode;
  final String jamMulai;
  final String jamSelesai;
  final String ruang;
  final String dosen;
  final int hari; // 1=Senin, 2=Selasa, ..., 7=Minggu
  final int sks;
}

/// Data jadwal demo — ditandai eksplisit sebagai demo, bukan jadwal resmi.
const List<JadwalItem> _demoJadwal = <JadwalItem>[
  JadwalItem(
    mataKuliah: 'Pemrograman Mobile',
    kode: 'TRM-501',
    jamMulai: '08:00',
    jamSelesai: '10:30',
    ruang: 'Lab Komputer 3',
    dosen: 'Dosen Demo A',
    hari: 1,
    sks: 3,
  ),
  JadwalItem(
    mataKuliah: 'Desain UI/UX',
    kode: 'TRM-502',
    jamMulai: '13:00',
    jamSelesai: '15:30',
    ruang: 'Ruang B-204',
    dosen: 'Dosen Demo B',
    hari: 1,
    sks: 3,
  ),
  JadwalItem(
    mataKuliah: 'Rekayasa Perangkat Lunak',
    kode: 'TRM-503',
    jamMulai: '10:00',
    jamSelesai: '12:00',
    ruang: 'Ruang A-101',
    dosen: 'Dosen Demo C',
    hari: 2,
    sks: 2,
  ),
  JadwalItem(
    mataKuliah: 'Basis Data',
    kode: 'TRM-504',
    jamMulai: '13:00',
    jamSelesai: '15:30',
    ruang: 'Lab Komputer 2',
    dosen: 'Dosen Demo D',
    hari: 2,
    sks: 3,
  ),
  JadwalItem(
    mataKuliah: 'Jaringan Komputer',
    kode: 'TRM-505',
    jamMulai: '08:00',
    jamSelesai: '10:00',
    ruang: 'Ruang C-301',
    dosen: 'Dosen Demo E',
    hari: 3,
    sks: 2,
  ),
  JadwalItem(
    mataKuliah: 'Pemrograman Mobile',
    kode: 'TRM-501',
    jamMulai: '10:00',
    jamSelesai: '12:00',
    ruang: 'Lab Komputer 3',
    dosen: 'Dosen Demo A',
    hari: 4,
    sks: 3,
  ),
  JadwalItem(
    mataKuliah: 'Desain UI/UX',
    kode: 'TRM-502',
    jamMulai: '08:00',
    jamSelesai: '10:00',
    ruang: 'Ruang B-204',
    dosen: 'Dosen Demo B',
    hari: 5,
    sks: 3,
  ),
  JadwalItem(
    mataKuliah: 'Rekayasa Perangkat Lunak',
    kode: 'TRM-503',
    jamMulai: '13:00',
    jamSelesai: '15:00',
    ruang: 'Ruang A-101',
    dosen: 'Dosen Demo C',
    hari: 5,
    sks: 2,
  ),
];

const List<String> _namaHari = <String>[
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen>
    with SingleTickerProviderStateMixin {
  bool _isHarian = true;

  // Mode harian: indeks hari (0=Senin, 6=Minggu)
  int _selectedDay = 0; // default: Senin

  // Mode mingguan: offset minggu dari minggu saat ini
  int _weekOffset = 0;

  @override
  void initState() {
    super.initState();
    // Set hari ke hari ini
    final int todayWeekday = DateTime.now().weekday; // 1=Senin, 7=Minggu
    _selectedDay = todayWeekday - 1;
  }

  List<JadwalItem> _getHarian(int hariIndex) {
    final int hari = hariIndex + 1; // 1=Senin
    return _demoJadwal.where((JadwalItem j) => j.hari == hari).toList()
      ..sort((JadwalItem a, JadwalItem b) => a.jamMulai.compareTo(b.jamMulai));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DarkHeader(
          title: 'Jadwal',
          subtitle: 'kuliah semester ini',
          decorations: const <Color>[Color(0xFF1E4FD8), Color(0xFF3CC8B4)],
          child: _buildModeToggle(),
        ),
        Expanded(child: _isHarian ? _buildHarian() : _buildMingguan()),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeButton(
              label: 'Harian',
              active: _isHarian,
              onTap: () => setState(() => _isHarian = true),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Mingguan',
              active: !_isHarian,
              onTap: () => setState(() => _isHarian = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarian() {
    return Column(
      children: <Widget>[
        Transform.translate(
          offset: const Offset(0, -26),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheetTop),
              ),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 16),
                _buildDaySelector(),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -26),
            child: _buildHarianList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: 7,
        itemBuilder: (BuildContext context, int index) {
          final bool active = _selectedDay == index;
          final bool hasClass = _getHarian(index).isNotEmpty;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: active ? 90 : 68,
                decoration: BoxDecoration(
                  color: active ? AppColors.navy : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: active
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _namaHari[index].substring(0, 3),
                      style: AppText.listTitle.copyWith(
                        color: active ? Colors.white : AppColors.navy,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasClass)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.royal,
                        ),
                      )
                    else
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHarianList() {
    final List<JadwalItem> items = _getHarian(_selectedDay);

    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available_outlined,
        title: 'Tidak ada kuliah',
        subtitle:
            'Tidak ada jadwal kuliah pada hari ${_namaHari[_selectedDay]}.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Staggered(
            index: index,
            child: _JadwalCard(item: items[index]),
          ),
        );
      },
    );
  }

  Widget _buildMingguan() {
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _weekOffset * 7));

    return Transform.translate(
      offset: const Offset(0, -26),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheetTop),
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            _buildWeekNav(startOfWeek),
            const SizedBox(height: 8),
            Expanded(child: _buildMinggualList(startOfWeek)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekNav(DateTime startOfWeek) {
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() => _weekOffset--),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.navy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${_formatDate(startOfWeek)} – ${_formatDate(endOfWeek)}',
              textAlign: TextAlign.center,
              style: AppText.listTitle,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _weekOffset++),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
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
    return '${date.day} ${months[date.month - 1]}';
  }

  Widget _buildMinggualList(DateTime startOfWeek) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      itemCount: 7,
      itemBuilder: (BuildContext context, int dayIndex) {
        final List<JadwalItem> items = _getHarian(dayIndex);
        final DateTime date = startOfWeek.add(Duration(days: dayIndex));
        final bool isToday = _isSameDay(date, DateTime.now());

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
                      color: isToday ? AppColors.navy : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _namaHari[dayIndex],
                      style: AppText.caption.copyWith(
                        color: isToday ? Colors.white : AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${date.day}/${date.month}',
                    style: AppText.caption.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Tidak ada kuliah',
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                )
              else
                for (final JadwalItem item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _JadwalCard(item: item, compact: true),
                  ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
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
        height: double.infinity,
        decoration: BoxDecoration(
          color: active ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.body.copyWith(
              color: active ? AppColors.navy : Colors.white,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _JadwalCard extends StatelessWidget {
  const _JadwalCard({required this.item, this.compact = false});

  final JadwalItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: compact ? 56 : 72,
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
                Row(
                  children: <Widget>[
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
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelAt(0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.sks} SKS',
                        style: AppText.caption.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.kode,
                  style: AppText.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 6),
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
                    const SizedBox(width: 12),
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
                if (!compact) ...<Widget>[
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.dosen,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.pastelAt(0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.navy),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppText.nameSmall),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Getter untuk jadwal hari ini - dipakai oleh HomeScreen
List<JadwalItem> getJadwalHariIni() {
  final int todayWeekday = DateTime.now().weekday; // 1=Senin, 7=Minggu
  return _demoJadwal.where((JadwalItem j) => j.hari == todayWeekday).toList()
    ..sort((JadwalItem a, JadwalItem b) => a.jamMulai.compareTo(b.jamMulai));
}
