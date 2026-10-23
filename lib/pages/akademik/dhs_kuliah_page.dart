import 'package:flutter/material.dart';

import '../../api/nilai_api.dart';
import '../../theme.dart';
import '../../widgets.dart';

// ─── DhsKuliahPage ────────────────────────────────────────────────────────────

/// Halaman DHS Kuliah — menampilkan nilai per mata kuliah dari API MockAPI.
/// Data diambil dari: GET /nilai?npm={npm}
class DhsKuliahPage extends StatefulWidget {
  const DhsKuliahPage({super.key, required this.npm});

  /// NPM mahasiswa untuk query ke API.
  final String npm;

  @override
  State<DhsKuliahPage> createState() => _DhsKuliahPageState();
}

class _DhsKuliahPageState extends State<DhsKuliahPage>
    with SingleTickerProviderStateMixin {
  final NilaiApi _api = NilaiApi();

  _PageState _state = _PageState.loading;
  List<NilaiItem> _data = <NilaiItem>[];
  String _errorMessage = '';

  // Tab semester yang dipilih (-1 = semua)
  int _selectedSemester = -1;
  // Semester yang di-expand (accordion)
  int? _expandedSemester;

  late final AnimationController _shimmerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _state = _PageState.loading;
      _data = <NilaiItem>[];
      _errorMessage = '';
    });
    try {
      final List<NilaiItem> items = await _api.fetchNilai(widget.npm);
      if (!mounted) return;
      setState(() {
        _data = items;
        _state = items.isEmpty ? _PageState.empty : _PageState.success;
        if (items.isNotEmpty) {
          // Expand semester terakhir secara default
          final List<int> semesters = _semesterList(items);
          _expandedSemester = semesters.isNotEmpty ? semesters.last : null;
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;
      final String msg = e.toString();
      setState(() {
        _state = _PageState.error;
        if (msg.contains('SocketException') ||
            msg.contains('TimeoutException') ||
            msg.contains('HandshakeException')) {
          _errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        } else if (msg.contains('FormatException') || msg.contains('JSON')) {
          _errorMessage = 'Format data dari server tidak valid.';
        } else if (msg.contains('HttpException')) {
          _errorMessage = 'Server mengembalikan error. Coba lagi nanti.';
        } else {
          _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        }
      });
    }
  }

  // ─── Helper ──────────────────────────────────────────────────────────────────

  List<int> _semesterList(List<NilaiItem> items) {
    final Set<int> set = <int>{};
    for (final NilaiItem n in items) {
      set.add(n.semester);
    }
    final List<int> list = set.toList()..sort();
    return list;
  }

  /// Hitung rata-rata angka mutu dari daftar nilai.
  double _ips(List<NilaiItem> items) {
    if (items.isEmpty) return 0;
    double totalAm = 0;
    for (final NilaiItem n in items) {
      totalAm += n.am;
    }
    // IPS = rata-rata am
    return totalAm / items.length;
  }

  double get _rataRataAm {
    if (_data.isEmpty) return 0;
    double totalAm = 0;
    for (final NilaiItem n in _data) {
      totalAm += n.am;
    }
    return totalAm / _data.length;
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: <Widget>[
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final List<int> semesters = _state == _PageState.success
        ? _semesterList(_data)
        : <int>[];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0F766E), Color(0xFF34D399)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            // Dekorasi lingkaran
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Baris judul + tombol back
                  Row(
                    children: <Widget>[
                      Semantics(
                        button: true,
                        label: 'Kembali',
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
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
                              'DHS Kuliah',
                              style: AppText.headerTitle.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Daftar Hasil Studi per Mata Kuliah',
                              style: AppText.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol refresh
                      Semantics(
                        button: true,
                        label: 'Muat ulang data',
                        child: GestureDetector(
                          onTap: _load,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_state == _PageState.success) ...<Widget>[
                    const SizedBox(height: 16),
                    // Ringkasan nilai dan jumlah mata kuliah dari respons API.
                    _buildSummaryChip(),
                    const SizedBox(height: 14),
                    // Tab filter semester
                    if (semesters.length > 1)
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: semesters.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (BuildContext ctx, int i) {
                            final bool isAll = i == 0;
                            final int sem = isAll ? -1 : semesters[i - 1];
                            final bool active = _selectedSemester == sem;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedSemester = sem;
                                _expandedSemester = sem == -1 ? null : sem;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: active
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  isAll ? 'Semua' : 'Smt $sem',
                                  style: AppText.caption.copyWith(
                                    color: active
                                        ? const Color(0xFF0F766E)
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          _StatItem(
            icon: Icons.star_outline_rounded,
            label: 'Rata-rata AM',
            value: _rataRataAm.toStringAsFixed(2),
          ),
          _vertDivider(),
          _StatItem(
            icon: Icons.library_books_outlined,
            label: 'Jml MK',
            value: '${_data.length}',
          ),
          _vertDivider(),
          _StatItem(
            icon: Icons.person_outline_rounded,
            label: 'NPM',
            value: widget.npm,
          ),
        ],
      ),
    );
  }

  Widget _vertDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _PageState.loading:
        return _buildSkeleton();
      case _PageState.error:
        return _buildError();
      case _PageState.empty:
        return _buildEmpty();
      case _PageState.success:
        return _buildSuccess();
    }
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      itemCount: 5,
      itemBuilder: (BuildContext ctx, int i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, _) {
              final double t = _shimmerCtrl.value;
              return Container(
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: <double>[
                      (t - 0.3).clamp(0, 1),
                      t.clamp(0, 1),
                      (t + 0.3).clamp(0, 1),
                    ],
                    colors: const <Color>[
                      Color(0xFFE2E8F0),
                      Color(0xFFF1F5F9),
                      Color(0xFFE2E8F0),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.dot.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppColors.dot,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: AppText.listTitle.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: AppText.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF0F766E), Color(0xFF34D399)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  'Coba Lagi',
                  style: AppText.listTitle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 36,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data nilai',
              style: AppText.listTitle.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 6),
            Text(
              'Data nilai untuk NPM ${widget.npm} belum tersedia\ndi sistem demo.',
              style: AppText.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    // Kelompokkan data per semester
    final List<int> semesters = _selectedSemester == -1
        ? _semesterList(_data)
        : <int>[_selectedSemester];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
      children: <Widget>[
        // Banner info API
        Staggered(index: 0, child: _buildApiBanner()),
        const SizedBox(height: 16),
        // Daftar per semester
        for (int si = 0; si < semesters.length; si++) ...<Widget>[
          Staggered(
            index: si + 1,
            child: _buildSemesterSection(semesters[si], si),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildApiBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.cloud_done_outlined,
            size: 15,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data diambil dari MockAPI — npm: ${widget.npm}. '
              'Data ini hanya untuk keperluan demonstrasi.',
              style: AppText.caption.copyWith(color: const Color(0xFF065F46)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterSection(int semester, int idx) {
    final List<NilaiItem> items = _data
        .where((NilaiItem n) => n.semester == semester)
        .toList();
    final bool expanded = _expandedSemester == semester;
    final double ips = _ips(items);
    final String thnAkademik = items.isNotEmpty ? items.first.thnAkademik : '-';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header accordion
          Semantics(
            button: true,
            label: 'Semester $semester, ${expanded ? 'tutup' : 'buka'} detail',
            child: InkWell(
              onTap: () => setState(() {
                _expandedSemester = expanded ? null : semester;
              }),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: <Widget>[
                    // Badge semester
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.pastelAt(idx),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '$semester',
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
                          Text('Semester $semester', style: AppText.listTitle),
                          Text(
                            'TA $thnAkademik  •  ${items.length} MK',
                            style: AppText.caption.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chip IPS
                    _ChipInfo(label: 'Avg AM', value: ips.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
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
          // Detail expandable
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: expanded
                ? Column(
                    children: <Widget>[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                        indent: 14,
                        endIndent: 14,
                      ),
                      _buildNilaiTable(items),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNilaiTable(List<NilaiItem> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      child: Column(
        children: <Widget>[
          // Header tabel
          _TableHeader(),
          const SizedBox(height: 6),
          // Baris data
          for (int i = 0; i < items.length; i++) ...<Widget>[
            _NilaiRow(item: items[i], index: i),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
          ],
          const SizedBox(height: 10),
          // Footer total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    'TOTAL ${items.length} MATA KULIAH',
                    style: AppText.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    items
                        .fold<double>(0, (double s, NilaiItem n) => s + n.mutu)
                        .toStringAsFixed(1),
                    style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
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

// ─── Enum State ───────────────────────────────────────────────────────────────

enum _PageState { loading, success, empty, error }

// ─── Widget _StatItem ─────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppText.cardTitle.copyWith(
              color: Colors.white,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
  }
}

// ─── Widget _ChipInfo ─────────────────────────────────────────────────────────

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
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: AppColors.muted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget _TableHeader ──────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'Kode MK',
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'UAS',
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'UTS',
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'NA',
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              'HM / Mutu',
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
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

// ─── Widget _NilaiRow ─────────────────────────────────────────────────────────

class _NilaiRow extends StatefulWidget {
  const _NilaiRow({required this.item, required this.index});

  final NilaiItem item;
  final int index;

  @override
  State<_NilaiRow> createState() => _NilaiRowState();
}

class _NilaiRowState extends State<_NilaiRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final Color hurufColor = Color(widget.item.hurufColorValue);

    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.pastelAt(widget.index),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            widget.item.kdMatkul
                                .substring(
                                  0,
                                  widget.item.kdMatkul.length.clamp(0, 2),
                                )
                                .toUpperCase(),
                            style: AppText.caption.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.item.kdMatkul,
                              style: AppText.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'NIP: ${widget.item.nip}',
                              style: AppText.caption.copyWith(
                                color: AppColors.muted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    widget.item.uas.toStringAsFixed(0),
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    widget.item.uts.toStringAsFixed(0),
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    widget.item.na.toStringAsFixed(1),
                    style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: hurufColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.item.hm,
                          style: AppText.caption.copyWith(
                            color: hurufColor,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        widget.item.mutu.toStringAsFixed(1),
                        style: AppText.caption.copyWith(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Detail expandable: komponen nilai lengkap
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Rincian Komponen Nilai',
                        style: AppText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: <Widget>[
                          _KomponenChip('UAS', widget.item.uas),
                          _KomponenChip('UTS', widget.item.uts),
                          _KomponenChip('Quis', widget.item.quis),
                          _KomponenChip('Tugas', widget.item.tugas),
                          _KomponenChip('Hadir', widget.item.hadir),
                          if (widget.item.seminar > 0)
                            _KomponenChip('Seminar', widget.item.seminar),
                          if (widget.item.bimbingan > 0)
                            _KomponenChip('Bimbingan', widget.item.bimbingan),
                          if (widget.item.makalah > 0)
                            _KomponenChip('Makalah', widget.item.makalah),
                          if (widget.item.lisan > 0)
                            _KomponenChip('Lisan', widget.item.lisan),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _InfoRow('TA', widget.item.thnAkademik),
                          ),
                          Expanded(
                            child: _InfoRow('AM', widget.item.am.toString()),
                          ),
                          Expanded(
                            child: _InfoRow(
                              'Mutu',
                              widget.item.mutu.toStringAsFixed(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _KomponenChip extends StatelessWidget {
  const _KomponenChip(this.label, this.value);

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}',
        style: AppText.caption.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppText.caption.copyWith(color: AppColors.muted, fontSize: 9),
        ),
        Text(
          value,
          style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
