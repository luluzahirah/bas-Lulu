import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/nilai_service.dart';
import '../../services/session_service.dart';
import '../../theme.dart';
import '../../widgets/components.dart';

/// Halaman KHS (Kartu Hasil Studi) untuk melihat nilai per semester,
/// menghitung IP Semester (IPS), IP Kumulatif (IPK), dan cetak/ekspor slip KHS.
class KhsPage extends StatefulWidget {
  const KhsPage({
    super.key,
    this.npm,
    this.nilaiServiceOverride,
  });

  final String? npm;
  final NilaiService? nilaiServiceOverride;

  @override
  State<KhsPage> createState() => _KhsPageState();
}

class _KhsPageState extends State<KhsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final NilaiService _nilaiService =
      widget.nilaiServiceOverride ?? nilaiService;

  String get _activeNpm {
    final String? sessionNpm = SessionService.instance.npm;
    return (widget.npm ?? sessionNpm ?? '12523030').trim();
  }

  void _handleBackToBeranda() {
    final ScaffoldState? scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
    }
  }

  String _selectedThnAkademik = '2024/2025';
  String _selectedSemester = '5';

  bool _isLoading = true;
  String? _errorMessage;
  List<KhsJoinedItem> _items = <KhsJoinedItem>[];
  KhsSummary? _summary;

  static const List<String> _thnAkademikOptions = <String>[
    '2024/2025',
    '2023/2024',
    '2025/2026',
  ];

  static const List<String> _semesterOptions = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];

  @override
  void initState() {
    super.initState();
    _loadKhs();
  }

  Future<void> _loadKhs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<KhsJoinedItem> data = await _nilaiService.fetchJoinedKhs(
        npm: _activeNpm,
        semester: _selectedSemester,
        thnAkademik: _selectedThnAkademik,
      );

      final KhsSummary summary = await _nilaiService.calculateKhsSummary(
        npm: _activeNpm,
        currentSemester: _selectedSemester,
        currentThnAkademik: _selectedThnAkademik,
      );

      if (!mounted) return;
      setState(() {
        _items = data;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  // ── Dialog Cetak / Export KHS ─────────────────────────────────────────────

  void _showPrintDialog() {
    final String mhsName =
        SessionService.instance.currentUser?.name ?? 'Sofi Putri Rahayu';
    final String prodi =
        SessionService.instance.currentUser?.prodi ?? 'Teknik Informatika';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Sheet Grabber
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Bar
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.print_rounded,
                    color: AppColors.royal,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pratinjau Cetak / Slip KHS',
                    style: AppText.nameSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),

              // Printable Slip Preview Container
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Kop Surat KHS
                        Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'KARTU HASIL STUDI (KHS)',
                                style: AppText.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                  color: AppColors.navy,
                                ),
                              ),
                              Text(
                                'BOASH APPLICATION SYSTEM (BAS)',
                                style: AppText.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.royal,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tahun Akademik $_selectedThnAkademik • Semester $_selectedSemester',
                                style: AppText.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1.5, height: 24),

                        // Identitas Mahasiswa
                        _slipRow('Nama Mahasiswa', mhsName),
                        _slipRow('NPM', _activeNpm),
                        _slipRow('Program Studi', prodi),
                        _slipRow('Semester / TA', 'Smt $_selectedSemester / $_selectedThnAkademik'),
                        const SizedBox(height: 14),

                        // Tabel Nilai Singkat
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            border: TableBorder.all(
                              color: const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                            columnWidths: const <int, TableColumnWidth>{
                              0: FlexColumnWidth(1.2),
                              1: FlexColumnWidth(3.5),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                              5: FlexColumnWidth(1.2),
                            },
                            children: <TableRow>[
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF2F6),
                                ),
                                children: <Widget>[
                                  _tableHeaderCell('Kode'),
                                  _tableHeaderCell('Mata Kuliah'),
                                  _tableHeaderCell('SKS'),
                                  _tableHeaderCell('Huruf'),
                                  _tableHeaderCell('Bobot'),
                                  _tableHeaderCell('Mutu'),
                                ],
                              ),
                              for (final KhsJoinedItem item in _items)
                                TableRow(
                                  children: <Widget>[
                                    _tableDataCell(item.kdMatkul),
                                    _tableDataCell(item.namaMatkul),
                                    _tableDataCell('${item.sks}', alignCenter: true),
                                    _tableDataCell(item.nilaiHuruf, alignCenter: true),
                                    _tableDataCell(item.bobot.toStringAsFixed(1), alignCenter: true),
                                    _tableDataCell(item.mutu.toStringAsFixed(1), alignCenter: true),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Summary KHS
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Column(
                            children: <Widget>[
                              _slipRow(
                                'Total SKS Semester Ini',
                                '${_summary?.totalSks ?? 0} SKS',
                                isBold: true,
                              ),
                              _slipRow(
                                'Total Mutu Semester Ini',
                                (_summary?.totalMutu ?? 0.0).toStringAsFixed(1),
                              ),
                              _slipRow(
                                'Indeks Prestasi Semester (IPS)',
                                _summary?.ipSemesterFormatted ?? '0.00',
                                isBold: true,
                                valueColor: AppColors.royal,
                              ),
                              const Divider(height: 12),
                              _slipRow(
                                'Indeks Prestasi Kumulatif (IPK)',
                                _summary?.ipkFormatted ?? '0.00',
                                isBold: true,
                                valueColor: const Color(0xFF0F766E),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tanda Tangan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text('Mahasiswa,', style: AppText.caption),
                                const SizedBox(height: 48),
                                Text(
                                  mhsName,
                                  style: AppText.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text('NPM: $_activeNpm', style: AppText.caption),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text('Pembimbing Akademik,', style: AppText.caption),
                                const SizedBox(height: 48),
                                Text(
                                  'Dr. Ir. Hendra, M.Kom.',
                                  style: AppText.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text('NIP: 198204122005011002', style: AppText.caption),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Salin Ringkasan'),
                      onPressed: () {
                        final String text = 'KHS Mahasiswa: $mhsName ($activeNpm)\n'
                            'Semester: $_selectedSemester ($_selectedThnAkademik)\n'
                            'Total SKS: ${_summary?.totalSks} SKS\n'
                            'IPS: ${_summary?.ipSemesterFormatted}\n'
                            'IPK: ${_summary?.ipkFormatted}';
                        Clipboard.setData(ClipboardData(text: text));
                        AppToast.showSuccess(
                          context,
                          'Ringkasan KHS berhasil disalin ke clipboard!',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Cetak Dokumen'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        AppToast.showSuccess(
                          context,
                          'Dokumen KHS siap dicetak / diekspor.',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _slipRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const Text(' :  '),
          Expanded(
            child: Text(
              value,
              style: AppText.body.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColors.navy,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppText.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _tableDataCell(String text, {bool alignCenter = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
        style: AppText.caption.copyWith(fontSize: 11),
      ),
    );
  }

  String get activeNpm => _activeNpm;

  // ── Build Method ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBackToBeranda();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.bg,
        drawer: const AppDrawer(currentRoute: '/khs'),
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Kembali ke Beranda',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _handleBackToBeranda,
          ),
          title: Text(
            'Kartu Hasil Studi (KHS)',
            style: AppText.nameSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Cetak / Ekspor KHS',
              icon: const Icon(Icons.print_rounded),
              onPressed: _items.isNotEmpty ? _showPrintDialog : null,
            ),
            Builder(
              builder: (BuildContext ctx) => IconButton(
                tooltip: 'Menu Navigasi',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadKhs,
          child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: <Widget>[
            // Filter Dropdowns
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: <Widget>[
                  // Dropdown Tahun Akademik
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Tahun Akademik',
                          style: AppText.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedThnAkademik,
                              style: AppText.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                              ),
                              items: _thnAkademikOptions.map((String opt) {
                                return DropdownMenuItem<String>(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                if (val != null) {
                                  setState(() => _selectedThnAkademik = val);
                                  _loadKhs();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Dropdown Semester
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Semester',
                          style: AppText.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedSemester,
                              style: AppText.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                              ),
                              items: _semesterOptions.map((String opt) {
                                return DropdownMenuItem<String>(
                                  value: opt,
                                  child: Text(
                                    'Smt $opt',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                if (val != null) {
                                  setState(() => _selectedSemester = val);
                                  _loadKhs();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Ringkasan Indeks Prestasi (IPS & IPK Cards)
            if (_isLoading)
              AppLoadingSkeleton.card(height: 110)
            else if (_summary != null)
              _buildSummaryCards(),

            const SizedBox(height: 16),

            // Title Tabel
            Row(
              children: <Widget>[
                Text(
                  'Daftar Nilai Semester $_selectedSemester',
                  style: AppText.listTitle,
                ),
                const Spacer(),
                if (_items.isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF2FF),
                      foregroundColor: AppColors.royal,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text(
                      'Cetak KHS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _showPrintDialog,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // State Data KHS
            if (_isLoading)
              AppLoadingSkeleton.table(rows: 4)
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal Memuat KHS',
                      style: AppText.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Coba Lagi'),
                      onPressed: _loadKhs,
                    ),
                  ],
                ),
              )
            else if (_items.isEmpty)
              AppEmptyState(
                icon: Icons.assignment_outlined,
                title: 'Nilai Semester $_selectedSemester Belum Ada',
                description:
                    'Tidak ditemukan rekaman nilai untuk Tahun Akademik $_selectedThnAkademik semester $_selectedSemester.',
              )
            else
              AppDataTable(
                minWidth: 780,
                columns: const <AppDataTableColumn>[
                  AppDataTableColumn(title: 'No', numeric: true),
                  AppDataTableColumn(title: 'Kode MK'),
                  AppDataTableColumn(title: 'Nama Mata Kuliah'),
                  AppDataTableColumn(title: 'SKS', numeric: true),
                  AppDataTableColumn(title: 'Nilai Angka', numeric: true),
                  AppDataTableColumn(title: 'Nilai Huruf'),
                  AppDataTableColumn(title: 'Bobot', numeric: true),
                  AppDataTableColumn(title: 'Mutu (SKS x Bobot)', numeric: true),
                ],
                rows: List<AppDataTableRow>.generate(_items.length, (int index) {
                  final KhsJoinedItem item = _items[index];
                  return AppDataTableRow(
                    cells: <Widget>[
                      Text(
                        '${index + 1}',
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        item.kdMatkul,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.royal,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        item.namaMatkul,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        '${item.sks}',
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        item.nilaiAngka.toStringAsFixed(1),
                        style: AppText.body.copyWith(fontSize: 12.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _colorForHuruf(item.nilaiHuruf).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.nilaiHuruf,
                          style: AppText.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _colorForHuruf(item.nilaiHuruf),
                          ),
                        ),
                      ),
                      Text(
                        item.bobot.toStringAsFixed(1),
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        item.mutu.toStringAsFixed(1),
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.royal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                }),
                footer: Row(
                  children: <Widget>[
                    Text(
                      'Total: ${_summary?.totalSks ?? 0} SKS • Mutu: ${_summary?.totalMutu.toStringAsFixed(1) ?? '0.0'}',
                      style: AppText.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'IP Semester (IPS): ${_summary?.ipSemesterFormatted ?? '0.00'}',
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.royal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // Keterangan Skala Bobot BAS
            _buildSkalaBobotCard(),
          ],
        ),
      ),
    ),
  );
}

  // ── Ringkasan Kartu IPS & IPK ─────────────────────────────────────────────

  Widget _buildSummaryCards() {
    final KhsSummary s = _summary!;
    return Row(
      children: <Widget>[
        // Card IPS
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF1E4FD8), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x331E4FD8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amberAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'IP Semester (IPS)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    s.ipSemesterFormatted,
                    style: AppText.loginTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.totalSks} SKS • Mutu ${s.totalMutu.toStringAsFixed(1)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Card IPK
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x330F766E),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.military_tech_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'IP Kumulatif (IPK)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    s.ipkFormatted,
                    style: AppText.loginTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Akumulasi ${s.totalSksKumulatif} SKS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Info Skala Bobot ──────────────────────────────────────────────────────

  Widget _buildSkalaBobotCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.royal,
              ),
              const SizedBox(width: 6),
              Text(
                'Pedoman Skala Bobot Nilai',
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const <Widget>[
              _SkalaPill(huruf: 'A', bobot: '4.0'),
              _SkalaPill(huruf: 'AB', bobot: '3.5'),
              _SkalaPill(huruf: 'B', bobot: '3.0'),
              _SkalaPill(huruf: 'BC', bobot: '2.5'),
              _SkalaPill(huruf: 'C', bobot: '2.0'),
              _SkalaPill(huruf: 'D', bobot: '1.0'),
              _SkalaPill(huruf: 'E', bobot: '0.0'),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForHuruf(String huruf) {
    switch (huruf.trim().toUpperCase()) {
      case 'A':
        return const Color(0xFF059669);
      case 'AB':
      case 'A/B':
      case 'B+':
        return const Color(0xFF0D9488);
      case 'B':
        return const Color(0xFF2563EB);
      case 'BC':
      case 'B/C':
      case 'C+':
        return const Color(0xFFD97706);
      case 'C':
        return const Color(0xFFEA580C);
      case 'D':
      case 'E':
      default:
        return const Color(0xFFDC2626);
    }
  }
}

class _SkalaPill extends StatelessWidget {
  const _SkalaPill({required this.huruf, required this.bobot});

  final String huruf;
  final String bobot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$huruf = $bobot',
        style: AppText.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
