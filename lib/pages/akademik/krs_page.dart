import 'package:flutter/material.dart';

import '../../models/pengajuan_studi_model.dart';
import '../../services/krs_service.dart';
import '../../services/pengajuan_service.dart';
import '../../services/session_service.dart';
import '../../theme.dart';
import '../../welcome.dart';
import '../../widgets/components.dart';

/// Halaman KRS (Kartu Rencana Studi) lengkap dengan 3 tab:
/// 1. Data KRS (GET /krs join /matkul)
/// 2. Form Pengajuan Studi (POST /pengajuan_studi)
/// 3. List Pengajuan (GET /pengajuan_studi & DELETE pembatalan)
class KrsPage extends StatefulWidget {
  const KrsPage({
    super.key,
    this.npm,
    this.initialTabIndex = 0,
    this.krsServiceOverride,
    this.pengajuanServiceOverride,
  });

  final String? npm;
  final int initialTabIndex;
  final KrsService? krsServiceOverride;
  final PengajuanService? pengajuanServiceOverride;

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController;
  late final KrsService _krsService = widget.krsServiceOverride ?? krsService;
  late final PengajuanService _pengajuanService =
      widget.pengajuanServiceOverride ?? pengajuanService;

  String get _activeNpm {
    final String? sessionNpm = SessionService.instance.npm;
    return (widget.npm ?? sessionNpm ?? '12523030').trim();
  }

  // ── Tab 1: Data KRS State ──
  bool _isLoadingKrs = true;
  String? _krsError;
  List<KrsJoinedItem> _allKrs = <KrsJoinedItem>[];
  String _selectedThnAkademik = 'Semua';
  String _selectedSemester = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  bool _isCardView = false; // Toggle tampilan mobile: Tabel vs Kartu

  // ── Tab 2: Form Pengajuan State ──
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _formJenis = 'Cuti';
  String _formThnAkademik = '2024/2025';
  String _formSemester = '5';
  final TextEditingController _alasanController = TextEditingController();
  bool _isSubmittingPengajuan = false;

  // ── Tab 3: List Pengajuan State ──
  bool _isLoadingPengajuan = true;
  String? _pengajuanError;
  List<PengajuanStudiModel> _pengajuanList = <PengajuanStudiModel>[];

  static const List<String> _thnAkademikOptions = <String>[
    'Semua',
    '2024/2025',
    '2023/2024',
    '2025/2026',
  ];

  static const List<String> _semesterOptions = <String>[
    'Semua',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];

  static const List<String> _jenisPengajuanOptions = <String>[
    'Cuti',
    'Aktif Kembali',
    'Pindah',
    'Mengundurkan Diri',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );

    _loadKrsData();
    _loadPengajuanData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  // ── Navigasi Kembali ke Beranda ───────────────────────────────────────────

  void _handleBackToBeranda() {
    final ScaffoldState? scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WelcomeScreen(
            user: SessionService.instance.currentUser ??
                SessionService.instance.currentUser!,
          ),
        ),
      );
    }
  }

  // ── Data Loaders ──────────────────────────────────────────────────────────

  Future<void> _loadKrsData() async {
    setState(() {
      _isLoadingKrs = true;
      _krsError = null;
    });

    try {
      final List<KrsJoinedItem> data = await _krsService.fetchJoinedKrs(
        npm: _activeNpm,
      );
      if (!mounted) return;
      setState(() {
        _allKrs = data;
        _isLoadingKrs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _krsError = e.toString().replaceAll('Exception:', '').trim();
        _isLoadingKrs = false;
      });
    }
  }

  Future<void> _loadPengajuanData() async {
    setState(() {
      _isLoadingPengajuan = true;
      _pengajuanError = null;
    });

    try {
      final List<PengajuanStudiModel> list =
          await _pengajuanService.fetchPengajuanList(npm: _activeNpm);
      if (!mounted) return;
      setState(() {
        _pengajuanList = list;
        _isLoadingPengajuan = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pengajuanError = e.toString().replaceAll('Exception:', '').trim();
        _isLoadingPengajuan = false;
      });
    }
  }

  // ── Filtered KRS ──────────────────────────────────────────────────────────

  List<KrsJoinedItem> get _filteredKrs {
    final String query = _searchController.text.trim().toLowerCase();
    return _allKrs.where((KrsJoinedItem item) {
      final bool matchThn = _selectedThnAkademik == 'Semua' ||
          item.thnAkademik == _selectedThnAkademik;
      final bool matchSem =
          _selectedSemester == 'Semua' || item.semester == _selectedSemester;
      final bool matchQuery = query.isEmpty ||
          item.kdMatkul.toLowerCase().contains(query) ||
          item.namaMatkul.toLowerCase().contains(query);
      return matchThn && matchSem && matchQuery;
    }).toList();
  }

  int get _totalSks {
    return _filteredKrs.fold(0, (int sum, KrsJoinedItem item) => sum + item.sks);
  }

  // ── Form Submission ───────────────────────────────────────────────────────

  Future<void> _handleSubmitPengajuan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String cleanAlasan = _alasanController.text.trim();
    if (cleanAlasan.length < 10) {
      AppToast.showError(context, 'Alasan minimal harus 10 karakter.');
      return;
    }

    setState(() => _isSubmittingPengajuan = true);

    try {
      await _pengajuanService.submitPengajuan(
        npm: _activeNpm,
        jenis: _formJenis ?? 'Cuti',
        thnAkademik: _formThnAkademik,
        semester: _formSemester,
        alasan: cleanAlasan,
      );

      if (!mounted) return;
      AppToast.showSuccess(context, 'Pengajuan studi berhasil dikirim!');

      // Reset form
      _alasanController.clear();
      setState(() {
        _formJenis = 'Cuti';
        _formThnAkademik = '2024/2025';
        _formSemester = '5';
      });

      // Reload list dan pindah ke tab riwayat
      _loadPengajuanData();
      _tabController.animateTo(2);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        'Gagal mengirim pengajuan: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingPengajuan = false);
      }
    }
  }

  // ── Batalkan Pengajuan ────────────────────────────────────────────────────

  Future<void> _handleDeletePengajuan(PengajuanStudiModel item) async {
    if (!item.isPending) {
      AppToast.showError(
        context,
        'Hanya pengajuan dengan status Pending yang dapat dibatalkan.',
      );
      return;
    }

    final bool confirm = await AppConfirmDialog.show(
      context,
      title: 'Batalkan Pengajuan?',
      message:
          'Apakah Anda yakin ingin membatalkan pengajuan "${item.jenis}" untuk semester ${item.semester}?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Kembali',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );

    if (!confirm || !mounted) return;

    try {
      final bool success = await _pengajuanService.deletePengajuan(item.id);
      if (!mounted) return;
      if (success) {
        AppToast.showSuccess(context, 'Pengajuan studi berhasil dibatalkan.');
        _loadPengajuanData();
      } else {
        AppToast.showError(context, 'Gagal membatalkan pengajuan.');
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        'Error: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

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
        drawer: const AppDrawer(currentRoute: '/krs'),
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
            'Kartu Rencana Studi (KRS)',
            style: AppText.nameSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: <Widget>[
            Builder(
              builder: (BuildContext ctx) => IconButton(
                tooltip: 'Menu Navigasi',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF60A5FA),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            labelStyle: AppText.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: AppText.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11.5,
            ),
            tabs: const <Tab>[
              Tab(
                icon: Icon(Icons.table_chart_rounded, size: 18),
                text: 'Data KRS',
              ),
              Tab(
                icon: Icon(Icons.edit_note_rounded, size: 20),
                text: 'Pengajuan',
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 18),
                text: 'Riwayat',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _buildTabKrs(),
            _buildTabFormPengajuan(),
            _buildTabListPengajuan(),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: View Data KRS ──────────────────────────────────────────────────

  Widget _buildTabKrs() {
    return RefreshIndicator(
      onRefresh: _loadKrsData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
        children: <Widget>[
          // Header Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF0E7490), Color(0xFF0284C7)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x260E7490),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'KRS Mahasiswa',
                        style: AppText.nameSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NPM: $_activeNpm • Terhubung MockAPI',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '$_totalSks',
                        style: AppText.nameSmall.copyWith(
                          color: const Color(0xFF0E7490),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Total SKS',
                        style: AppText.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter Controls Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Filter Tahun Akademik
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Tahun Akademik',
                            style: AppText.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedThnAkademik,
                                style: AppText.body.copyWith(
                                  fontSize: 12,
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
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() => _selectedThnAkademik = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filter Semester
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Semester',
                            style: AppText.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedSemester,
                                style: AppText.body.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navy,
                                ),
                                items: _semesterOptions.map((String opt) {
                                  return DropdownMenuItem<String>(
                                    value: opt,
                                    child: Text(
                                      opt == 'Semua' ? 'Semua Sem.' : 'Smt $opt',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() => _selectedSemester = val);
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
                const SizedBox(height: 10),

                // Search Input
                TextField(
                  controller: _searchController,
                  style: AppText.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari kode / nama mata kuliah...',
                    hintStyle: AppText.caption.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.royal,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Header Baris Daftar dengan Tombol Toggle Tampilan (Tabel / Kartu)
          Row(
            children: <Widget>[
              Text(
                'Mata Kuliah Terdaftar',
                style: AppText.listTitle.copyWith(fontSize: 15),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      onTap: () => setState(() => _isCardView = false),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(9),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: !_isCardView
                            ? const Color(0xFFD6E4FF)
                            : Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.table_rows_rounded,
                              size: 15,
                              color: !_isCardView
                                  ? AppColors.royal
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tabel',
                              style: AppText.caption.copyWith(
                                fontWeight: !_isCardView
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: !_isCardView
                                    ? AppColors.royal
                                    : AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isCardView = true),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(9),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: _isCardView
                            ? const Color(0xFFD6E4FF)
                            : Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.view_agenda_rounded,
                              size: 15,
                              color: _isCardView
                                  ? AppColors.royal
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kartu',
                              style: AppText.caption.copyWith(
                                fontWeight: _isCardView
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: _isCardView
                                    ? AppColors.royal
                                    : AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content State (Loading, Error, Empty, DataTable/CardView)
          if (_isLoadingKrs)
            AppLoadingSkeleton.table(rows: 5)
          else if (_krsError != null)
            Container(
              padding: const EdgeInsets.all(18),
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
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal Memuat Data KRS',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _krsError!,
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
                    onPressed: _loadKrsData,
                  ),
                ],
              ),
            )
          else if (_filteredKrs.isEmpty)
            AppEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Tidak Ada Data KRS',
              description:
                  'Tidak ditemukan mata kuliah untuk filter yang dipilih.',
              actionLabel: 'Reset Filter',
              onAction: () {
                setState(() {
                  _selectedThnAkademik = 'Semua';
                  _selectedSemester = 'Semua';
                  _searchController.clear();
                });
              },
            )
          else if (_isCardView)
            _buildCardListView()
          else
            _buildDataTableView(),
        ],
      ),
    );
  }

  // ── Mode Tampilan Tabel ───────────────────────────────────────────────────

  Widget _buildDataTableView() {
    return AppDataTable(
      minWidth: 720,
      columns: const <AppDataTableColumn>[
        AppDataTableColumn(title: 'No', numeric: true),
        AppDataTableColumn(title: 'Kode MK'),
        AppDataTableColumn(title: 'Nama Mata Kuliah'),
        AppDataTableColumn(title: 'Kelas'),
        AppDataTableColumn(title: 'SKS', numeric: true),
        AppDataTableColumn(title: 'Semester'),
        AppDataTableColumn(title: 'Thn Akademik'),
        AppDataTableColumn(title: 'Status KRS'),
      ],
      rows: List<AppDataTableRow>.generate(_filteredKrs.length, (int index) {
        final KrsJoinedItem item = _filteredKrs[index];
        return AppDataTableRow(
          cells: <Widget>[
            Text(
              '${index + 1}',
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              item.kdMatkul,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.royal,
                fontSize: 12,
              ),
            ),
            Text(
              item.namaMatkul,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.kdKelas,
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
            Text(
              '${item.sks}',
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            Text(
              'Semester ${item.semester}',
              style: AppText.body.copyWith(fontSize: 12),
            ),
            Text(
              item.thnAkademik,
              style: AppText.caption.copyWith(fontSize: 11),
            ),
            Tooltip(
              message:
                  'Status KRS: ${item.isActive ? "1 = Aktif" : "0 = Tidak Aktif"}',
              child: AppStatusBadge.fromStatus(
                item.status,
                customLabel: item.isActive ? '1 (Aktif)' : '0 (Tidak Aktif)',
              ),
            ),
          ],
        );
      }),
      footer: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Menampilkan ${_filteredKrs.length} mata kuliah',
              style: AppText.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total: $_totalSks SKS',
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.royal,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode Tampilan Kartu (Sangat Ramah Layar Mobile) ────────────────────────

  Widget _buildCardListView() {
    return Column(
      children: <Widget>[
        for (int i = 0; i < _filteredKrs.length; i++) ...<Widget>[
          _buildKrsCardItem(_filteredKrs[i], i + 1),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: <Widget>[
              Text(
                'Total ${_filteredKrs.length} Mata Kuliah',
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: $_totalSks SKS',
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
      ],
    );
  }

  Widget _buildKrsCardItem(KrsJoinedItem item, int nomor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.kdMatkul,
                  style: AppText.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.royal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Kelas ${item.kdKelas}',
                  style: AppText.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Spacer(),
              Tooltip(
                message:
                    'Status KRS: ${item.isActive ? "1 = Aktif" : "0 = Tidak Aktif"}',
                child: AppStatusBadge.fromStatus(
                  item.status,
                  customLabel: item.isActive ? '1 (Aktif)' : '0 (Tidak Aktif)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.namaMatkul,
            style: AppText.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Text(
                '${item.sks} SKS',
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.royal,
                ),
              ),
              const Text(' • '),
              Text(
                'Semester ${item.semester}',
                style: AppText.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Text(' • '),
              Expanded(
                child: Text(
                  item.thnAkademik,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Form Pengajuan Studi ───────────────────────────────────────────

  Widget _buildTabFormPengajuan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 36),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Banner Pengantar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF5B3FD1), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x335B3FD1),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Formulir Pengajuan Studi',
                          style: AppText.nameSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ajukan permohonan Cuti, Aktif Kembali, Pindah, atau Pengunduran Diri.',
                          style: AppText.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.3,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card Form Input (Anti-overflow untuk layar sempit)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Jenis Pengajuan
                  Text(
                    'Jenis Pengajuan *',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _formJenis,
                    style: AppText.body.copyWith(
                      color: AppColors.navy,
                      fontSize: 13,
                    ),
                    decoration: _inputDecoration(
                      hint: 'Pilih jenis pengajuan',
                    ),
                    items: _jenisPengajuanOptions.map((String opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(
                          opt,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() => _formJenis = val);
                    },
                    validator: (String? val) =>
                        val == null || val.isEmpty ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 14),

                  // Row: Tahun Akademik & Semester (Bebas overflow)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Tahun Akademik *',
                              style: AppText.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _formThnAkademik,
                              style: AppText.body.copyWith(
                                color: AppColors.navy,
                                fontSize: 12.5,
                              ),
                              decoration: _inputDecoration(
                                hint: 'Tahun',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              items: const <String>[
                                '2024/2025',
                                '2023/2024',
                                '2025/2026',
                              ].map((String opt) {
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
                                  setState(() => _formThnAkademik = val);
                                }
                              },
                              validator: (String? val) =>
                                  val == null || val.isEmpty ? 'Wajib' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Semester *',
                              style: AppText.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _formSemester,
                              style: AppText.body.copyWith(
                                color: AppColors.navy,
                                fontSize: 12.5,
                              ),
                              decoration: _inputDecoration(
                                hint: 'Semester',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              items: const <String>[
                                '1',
                                '2',
                                '3',
                                '4',
                                '5',
                                '6',
                                '7',
                                '8',
                              ].map((String opt) {
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
                                  setState(() => _formSemester = val);
                                }
                              },
                              validator: (String? val) =>
                                  val == null || val.isEmpty ? 'Wajib' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Alasan (Textarea)
                  Text(
                    'Alasan Pengajuan Studi *',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _alasanController,
                    maxLines: 4,
                    style: AppText.body.copyWith(fontSize: 13),
                    decoration: _inputDecoration(
                      hint:
                          'Jelaskan alasan pengajuan secara rinci (minimal 10 karakter)...',
                    ).copyWith(
                      alignLabelWithHint: true,
                    ),
                    validator: (String? val) {
                      final String clean = (val ?? '').trim();
                      if (clean.isEmpty) {
                        return 'Alasan pengajuan wajib diisi.';
                      }
                      if (clean.length < 10) {
                        return 'Alasan minimal harus 10 karakter (saat ini ${clean.length}).';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),

                  // Row Keterangan Helper (Dengan Expanded untuk mencegah overflow 50px)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Minimal 10 karakter • Otomatis berstatus "pending"',
                          style: AppText.caption.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_alasanController.text.trim().length} karakter',
                        style: AppText.caption.copyWith(
                          color: _alasanController.text.trim().length >= 10
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tombol Kirim Pengajuan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 1.5,
                      ),
                      icon: _isSubmittingPengajuan
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _isSubmittingPengajuan
                            ? 'Mengirim Pengajuan...'
                            : 'Kirim Pengajuan Studi',
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      onPressed:
                          _isSubmittingPengajuan ? null : _handleSubmitPengajuan,
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

  // ── Tab 3: List Riwayat Pengajuan ─────────────────────────────────────────

  Widget _buildTabListPengajuan() {
    return RefreshIndicator(
      onRefresh: _loadPengajuanData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Riwayat Pengajuan Studi',
                  style: AppText.listTitle.copyWith(fontSize: 15),
                ),
              ),
              IconButton(
                tooltip: 'Muat Ulang',
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: _loadPengajuanData,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_isLoadingPengajuan)
            AppLoadingSkeleton.table(rows: 4)
          else if (_pengajuanError != null)
            Container(
              padding: const EdgeInsets.all(18),
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
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal Memuat Riwayat Pengajuan',
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pengajuanError!,
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
                    onPressed: _loadPengajuanData,
                  ),
                ],
              ),
            )
          else if (_pengajuanList.isEmpty)
            AppEmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: 'Belum Ada Pengajuan',
              description:
                  'Anda belum pernah membuat permohonan pengajuan studi.',
              actionLabel: 'Buat Pengajuan Baru',
              onAction: () => _tabController.animateTo(1),
            )
          else
            AppDataTable(
              minWidth: 800,
              columns: const <AppDataTableColumn>[
                AppDataTableColumn(title: 'No', numeric: true),
                AppDataTableColumn(title: 'Jenis Pengajuan'),
                AppDataTableColumn(title: 'Thn Akademik'),
                AppDataTableColumn(title: 'Semester'),
                AppDataTableColumn(title: 'Alasan'),
                AppDataTableColumn(title: 'Tanggal'),
                AppDataTableColumn(title: 'Status'),
                AppDataTableColumn(title: 'Catatan'),
                AppDataTableColumn(title: 'Aksi'),
              ],
              rows: List<AppDataTableRow>.generate(_pengajuanList.length, (int index) {
                final PengajuanStudiModel item = _pengajuanList[index];
                return AppDataTableRow(
                  cells: <Widget>[
                    Text(
                      '${index + 1}',
                      style: AppText.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.jenis,
                        style: AppText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3730A3),
                        ),
                      ),
                    ),
                    Text(
                      item.thnAkademik,
                      style: AppText.caption.copyWith(fontSize: 11.5),
                    ),
                    Text(
                      'Smt ${item.semester}',
                      style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        item.alasan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(fontSize: 11.5),
                      ),
                    ),
                    Text(
                      _formatDate(item.tanggalPengajuan),
                      style: AppText.caption.copyWith(fontSize: 11),
                    ),
                    AppStatusBadge.fromStatus(item.status),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        item.catatan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (item.isPending)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          foregroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 13),
                        label: const Text(
                          'Batalkan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _handleDeletePengajuan(item),
                      )
                    else
                      Text(
                        'Selesai',
                        style: AppText.caption.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                      ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  // ── Helper UI ─────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.caption.copyWith(
        color: const Color(0xFF94A3B8),
        fontSize: 12,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: const Color(0xFF64748B))
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.royal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }

  String _formatDate(String isoString) {
    final DateTime? dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    final DateTime local = dt.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = _monthName(local.month);
    final String year = local.year.toString();
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  String _monthName(int month) {
    const List<String> m = <String>[
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
    if (month >= 1 && month <= 12) return m[month - 1];
    return '';
  }
}
