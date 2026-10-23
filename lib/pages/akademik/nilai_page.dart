import 'package:flutter/material.dart';

import '../../api/nilai_api.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Halaman Nilai — mengambil data nilai dari MockAPI berdasarkan NPM.
/// Endpoint: GET /nilai?npm={npm}
class NilaiPage extends StatefulWidget {
  const NilaiPage({super.key, this.npm});

  /// NPM mahasiswa. Jika null, gunakan NPM demo default.
  final String? npm;

  @override
  State<NilaiPage> createState() => _NilaiPageState();
}

class _NilaiPageState extends State<NilaiPage> {
  final NilaiApi _api = NilaiApi();

  _LoadState _state = _LoadState.loading;
  List<NilaiItem> _items = <NilaiItem>[];
  String _errMsg = '';

  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  String get _npm => widget.npm ?? '12523030';

  Future<void> _load() async {
    setState(() {
      _state = _LoadState.loading;
      _items = <NilaiItem>[];
    });
    try {
      final List<NilaiItem> result = await _api.fetchNilai(_npm);
      if (!mounted) return;
      setState(() {
        _items = result;
        _state = result.isEmpty ? _LoadState.empty : _LoadState.success;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      final String msg = e.toString();
      setState(() {
        _state = _LoadState.error;
        if (msg.contains('SocketException') ||
            msg.contains('TimeoutException')) {
          _errMsg = 'Tidak dapat terhubung ke server. Periksa koneksi.';
        } else {
          _errMsg = 'Gagal memuat data nilai. Coba lagi.';
        }
      });
    }
  }

  // ─── Hitung statistik ─────────────────────────────────────────────────────

  double get _avgAm {
    if (_items.isEmpty) return 0;
    double total = 0;
    for (final NilaiItem n in _items) {
      total += n.am;
    }
    return total / _items.length;
  }

  double get _totalMutu {
    double total = 0;
    for (final NilaiItem n in _items) {
      total += n.mutu;
    }
    return total;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Nilai',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[
          Semantics(
            button: true,
            label: 'Muat ulang',
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              tooltip: 'Muat ulang',
              onPressed: _load,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return _buildSkeleton();
      case _LoadState.error:
        return _buildError();
      case _LoadState.empty:
        return _buildEmpty();
      case _LoadState.success:
        return _buildSuccess();
    }
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: 6,
      itemBuilder: (_, int i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedBuilder(
          animation: _shimmer,
          builder: (_, _) {
            return Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: <double>[
                    (_shimmer.value - 0.3).clamp(0, 1),
                    _shimmer.value.clamp(0, 1),
                    (_shimmer.value + 0.3).clamp(0, 1),
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
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.dot),
            const SizedBox(height: 12),
            Text('Gagal memuat data', style: AppText.listTitle),
            const SizedBox(height: 8),
            Text(
              _errMsg,
              style: AppText.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(24),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text('Belum ada data nilai', style: AppText.listTitle),
          const SizedBox(height: 6),
          Text(
            'Nilai untuk NPM $_npm\nbelum tersedia di sistem demo.',
            style: AppText.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: <Widget>[
        // Kartu ringkasan
        Staggered(index: 0, child: _buildSummary()),
        const SizedBox(height: 12),
        // Banner API
        Staggered(index: 1, child: _buildApiBanner()),
        const SizedBox(height: 16),
        Staggered(
          index: 2,
          child: Text(
            'Nilai Mata Kuliah (${_items.length} MK)',
            style: AppText.listTitle,
          ),
        ),
        const SizedBox(height: 12),
        // Daftar nilai
        for (int i = 0; i < _items.length; i++)
          Staggered(
            index: i + 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NilaiCard(item: _items[i], index: i),
            ),
          ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.g1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1E4FD8).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SummaryItem(
              label: 'Rata AM',
              value: _avgAm.toStringAsFixed(2),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _SummaryItem(
              label: 'Total Mutu',
              value: _totalMutu.toStringAsFixed(1),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _SummaryItem(label: 'Jumlah MK', value: '${_items.length}'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            size: 14,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data diambil dari API — npm: $_npm. '
              'Hanya untuk keperluan demonstrasi.',
              style: AppText.caption.copyWith(color: const Color(0xFF065F46)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Enum ─────────────────────────────────────────────────────────────────────

enum _LoadState { loading, success, empty, error }

// ─── Widget _SummaryItem ──────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: AppText.name.copyWith(color: Colors.white)),
        Text(
          label,
          style: AppText.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ─── Widget _NilaiCard ────────────────────────────────────────────────────────

class _NilaiCard extends StatefulWidget {
  const _NilaiCard({required this.item, required this.index});

  final NilaiItem item;
  final int index;

  @override
  State<_NilaiCard> createState() => _NilaiCardState();
}

class _NilaiCardState extends State<_NilaiCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final Color hurufColor = Color(widget.item.hurufColorValue);

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
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: <Widget>[
                pastelTile(Icons.book_outlined, widget.index),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.item.kdMatkul,
                        style: AppText.listTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'TA ${widget.item.thnAkademik}  •  Smt ${widget.item.semester}',
                        style: AppText.caption.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Nilai & huruf
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hurufColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.item.hm,
                          style: AppText.listTitle.copyWith(
                            color: hurufColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NA: ${widget.item.na.toStringAsFixed(1)}',
                      style: AppText.caption.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          // Detail expandable
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Rincian Komponen',
                            style: AppText.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _komponen(
                            'UAS',
                            widget.item.uas,
                            'UTS',
                            widget.item.uts,
                          ),
                          const SizedBox(height: 4),
                          _komponen(
                            'Quis',
                            widget.item.quis,
                            'Tugas',
                            widget.item.tugas,
                          ),
                          const SizedBox(height: 4),
                          _komponen(
                            'Hadir',
                            widget.item.hadir,
                            'AM',
                            widget.item.am,
                          ),
                          const SizedBox(height: 4),
                          _komponen(
                            'Mutu',
                            widget.item.mutu,
                            'NIP',
                            null,
                            strVal: widget.item.nip,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _komponen(
    String l1,
    double? v1,
    String l2,
    double? v2, {
    String? strVal,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _KomponenRow(
            label: l1,
            value: v1 != null
                ? v1.toStringAsFixed(v1 == v1.truncateToDouble() ? 0 : 1)
                : strVal ?? '-',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KomponenRow(
            label: l2,
            value: v2 != null
                ? v2.toStringAsFixed(v2 == v2.truncateToDouble() ? 0 : 1)
                : strVal ?? '-',
          ),
        ),
      ],
    );
  }
}

class _KomponenRow extends StatelessWidget {
  const _KomponenRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: AppText.caption.copyWith(color: AppColors.muted)),
          Text(
            value,
            style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
