import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bas/config/api_config.dart';
import 'package:bas/models/khs_nilai_model.dart';
import 'package:bas/models/krs_model.dart';
import 'package:bas/models/matkul_model.dart';
import 'package:bas/models/pengajuan_studi_model.dart';
import 'package:bas/pages/akademik/khs_page.dart';
import 'package:bas/pages/akademik/krs_page.dart';
import 'package:bas/pages/akademik/pengajuan_studi_page.dart';
import 'package:bas/services/krs_service.dart';
import 'package:bas/services/matkul_service.dart';
import 'package:bas/services/nilai_service.dart';
import 'package:bas/services/pengajuan_service.dart';
import 'package:bas/widgets/components.dart';

class _TestNilaiService extends NilaiService {
  @override
  Future<List<KhsJoinedItem>> fetchJoinedKhs({
    required String npm,
    String? semester,
    String? thnAkademik,
  }) async {
    return <KhsJoinedItem>[
      const KhsJoinedItem(
        nilai: KhsNilaiModel(
          id: '1',
          npm: '12523030',
          kdMatkul: 'GC327',
          thnAkademik: '2024/2025',
          semester: '5',
          nilaiAngka: 85,
          nilaiHuruf: 'A',
          bobot: 4.0,
        ),
        matkul: MatkulModel(
          id: '1',
          kdMatkul: 'GC327',
          namaMatkul: 'Pemrograman Mobile',
          sks: 3,
          semester: '5',
        ),
      ),
    ];
  }

  @override
  Future<KhsSummary> calculateKhsSummary({
    required String npm,
    required String currentSemester,
    String? currentThnAkademik,
  }) async {
    return const KhsSummary(
      totalSks: 3,
      totalMutu: 12.0,
      ipSemester: 4.0,
      ipk: 3.9,
      totalSksKumulatif: 15,
      totalMutuKumulatif: 58.5,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Serialization & Helpers Tests', () {
    test('KrsModel parses JSON properly and reflects isActive', () {
      final KrsModel activeKrs = KrsModel.fromJson(<String, dynamic>{
        'id': '119308',
        'npm': '12523030',
        'kd_matkul': 'GC327',
        'kd_kelas': 'A',
        'thn_akademik': '2023/2024',
        'semester': '1',
        'status': 1,
      });

      expect(activeKrs.id, '119308');
      expect(activeKrs.npm, '12523030');
      expect(activeKrs.kdMatkul, 'GC327');
      expect(activeKrs.kdKelas, 'A');
      expect(activeKrs.isActive, isTrue);

      final KrsModel inactiveKrs = KrsModel.fromJson(<String, dynamic>{
        'id': '119311',
        'npm': '12523030',
        'kd_matkul': 'GC330',
        'status': 0,
        'thn_akademik': '2024/2025',
        'semester': '5',
      });
      expect(inactiveKrs.isActive, isFalse);
    });

    test('MatkulModel parses JSON properly', () {
      final MatkulModel matkul = MatkulModel.fromJson(<String, dynamic>{
        'id': '1',
        'kd_matkul': 'GC327',
        'nama_matkul': 'Pemrograman Mobile',
        'sks': 3,
        'semester': 5,
      });

      expect(matkul.kdMatkul, 'GC327');
      expect(matkul.namaMatkul, 'Pemrograman Mobile');
      expect(matkul.sks, 3);
      expect(matkul.semester, '5');
    });

    test('KhsNilaiModel calculates standard grading scale correctly', () {
      expect(KhsNilaiModel.bobotFromHuruf('A'), 4.0);
      expect(KhsNilaiModel.bobotFromHuruf('AB'), 3.5);
      expect(KhsNilaiModel.bobotFromHuruf('B'), 3.0);
      expect(KhsNilaiModel.bobotFromHuruf('BC'), 2.5);
      expect(KhsNilaiModel.bobotFromHuruf('C'), 2.0);
      expect(KhsNilaiModel.bobotFromHuruf('D'), 1.0);
      expect(KhsNilaiModel.bobotFromHuruf('E'), 0.0);

      final KhsNilaiModel model = KhsNilaiModel.fromJson(<String, dynamic>{
        'id': '1',
        'npm': '12523030',
        'kd_matkul': 'GC101',
        'thn_akademik': '2023/2024',
        'semester': '1',
        'nilai_angka': 86.5,
        'nilai_huruf': 'A',
      });
      expect(model.bobot, 4.0);
      expect(model.nilaiAngka, 86.5);
    });

    test('PengajuanStudiModel checks status helpers properly', () {
      final PengajuanStudiModel pending =
          PengajuanStudiModel.fromJson(<String, dynamic>{
        'id': '1',
        'npm': '12523030',
        'jenis': 'Cuti',
        'thn_akademik': '2024/2025',
        'semester': '5',
        'alasan': 'Magang kerja industri di luar daerah',
        'status': 'pending',
      });
      expect(pending.isPending, isTrue);
      expect(pending.isDisetujui, isFalse);
      expect(pending.isDitolak, isFalse);

      final PengajuanStudiModel disetujui =
          PengajuanStudiModel.fromJson(<String, dynamic>{
        'id': '2',
        'npm': '12523030',
        'jenis': 'Aktif Kembali',
        'thn_akademik': '2024/2025',
        'semester': '5',
        'alasan': 'Melanjutkan kuliah kembali setelah cuti',
        'status': 'disetujui',
      });
      expect(disetujui.isDisetujui, isTrue);

      final PengajuanStudiModel ditolak =
          PengajuanStudiModel.fromJson(<String, dynamic>{
        'id': '3',
        'npm': '12523030',
        'jenis': 'Pindah',
        'thn_akademik': '2023/2024',
        'semester': '2',
        'alasan': 'Permohonan pindah jadwal kuliah',
        'status': 'ditolak',
      });
      expect(ditolak.isDitolak, isTrue);
    });
  });

  group('Service Layer & Calculations Tests', () {
    test('ApiConfig reads default and supports override and reset', () {
      expect(ApiConfig.baseUrl, contains('mockapi.io'));
      expect(ApiConfig.krsUrl, contains('/krs'));
      expect(ApiConfig.matkulUrl, contains('/matkul'));
      expect(ApiConfig.nilaiUrl, contains('/nilai'));
      expect(ApiConfig.pengajuanUrl, contains('/pengajuan_studi'));

      ApiConfig.setBaseUrl('https://example.com/api');
      expect(ApiConfig.baseUrl, 'https://example.com/api');
      expect(ApiConfig.krsUrl, 'https://example.com/api/krs');

      ApiConfig.resetBaseUrl();
      expect(ApiConfig.baseUrl, ApiConfig.defaultBaseUrl);
    });

    test('MatkulService loads courses with map keying', () async {
      final MatkulService service = MatkulService();
      final List<MatkulModel> list = await service.fetchMatkulList();
      expect(list, isNotEmpty);

      final Map<String, MatkulModel> map = await service.fetchMatkulMap();
      expect(map.containsKey('GC327'), isTrue);
      expect(map['GC327']?.namaMatkul, 'Pemrograman Mobile');
      expect(map['GC327']?.sks, 3);
    });

    test('KrsJoinedItem falls back to kdMatkul if matkul is not found', () {
      const KrsModel krs = KrsModel(
        id: '1',
        npm: '12523030',
        kdMatkul: 'GC999',
        kdKelas: 'A',
        thnAkademik: '2024/2025',
        semester: '5',
        status: 1,
      );

      const KrsJoinedItem fallbackItem = KrsJoinedItem(krs: krs, matkul: null);
      // Fallback harus berupa kdMatkul, BUKAN placeholder 'Mata Kuliah XXX'
      expect(fallbackItem.namaMatkul, 'GC999');
    });

    test('KrsService fetchJoinedKrs joins correctly with /matkul data', () async {
      final KrsService service = KrsService();
      final List<KrsJoinedItem> joined = await service.fetchJoinedKrs(
        npm: '12523030',
      );
      expect(joined, isNotEmpty);
      final KrsJoinedItem mobile = joined.firstWhere(
        (KrsJoinedItem item) => item.kdMatkul == 'GC327',
      );
      expect(mobile.namaMatkul, 'Pemrograman Mobile');
      expect(mobile.sks, 3);
    });

    test('NilaiService calculateKhsSummary computes IPS and IPK correctly', () async {
      final NilaiService service = NilaiService();
      final KhsSummary summary = await service.calculateKhsSummary(
        npm: '12523030',
        currentSemester: '5',
        currentThnAkademik: '2024/2025',
      );

      expect(summary.totalSks, 12);
      expect(summary.totalMutu, 46.5);
      expect(summary.ipSemesterFormatted, '3.88');
      expect(summary.ipk, greaterThan(3.5));
    });

    test('PengajuanService submits, lists, and deletes pending requests', () async {
      final PengajuanService service = PengajuanService();
      final List<PengajuanStudiModel> initial =
          await service.fetchPengajuanList(npm: '12523030');
      expect(initial, isNotEmpty);

      // Submit new
      final PengajuanStudiModel created = await service.submitPengajuan(
        npm: '12523030',
        jenis: 'Cuti',
        thnAkademik: '2025/2026',
        semester: '6',
        alasan: 'Alasan pengajuan studi pengujian minimal 10 karakter',
      );
      expect(created.isPending, isTrue);
      expect(created.jenis, 'Cuti');

      // Verify list has new item
      final List<PengajuanStudiModel> afterAdd =
          await service.fetchPengajuanList(npm: '12523030');
      expect(afterAdd.any((PengajuanStudiModel p) => p.id == created.id), isTrue);

      // Delete
      final bool deleted = await service.deletePengajuan(created.id);
      expect(deleted, isTrue);
    });

    test('PengajuanService validates minimum reason length of 10 characters', () async {
      final PengajuanService service = PengajuanService();
      expect(
        () => service.submitPengajuan(
          npm: '12523030',
          jenis: 'Cuti',
          thnAkademik: '2024/2025',
          semester: '5',
          alasan: 'Pendek',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Reusable Components Widget Tests', () {
    testWidgets('AppStatusBadge renders all variants correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                AppStatusBadge.fromStatus(1),
                AppStatusBadge.fromStatus('pending'),
                AppStatusBadge.fromStatus(0),
                AppStatusBadge.fromStatus('disetujui'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Tidak Aktif'), findsOneWidget);
      expect(find.text('Disetujui'), findsOneWidget);
    });

    testWidgets('AppDataTable renders responsive columns and rows', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable(
              columns: const <AppDataTableColumn>[
                AppDataTableColumn(title: 'Kolom A'),
                AppDataTableColumn(title: 'Kolom B'),
              ],
              rows: const <AppDataTableRow>[
                AppDataTableRow(cells: <Widget>[Text('A1'), Text('B1')]),
                AppDataTableRow(cells: <Widget>[Text('A2'), Text('B2')]),
              ],
              footer: const Text('Total Baris: 2'),
            ),
          ),
        ),
      );

      expect(find.text('Kolom A'), findsOneWidget);
      expect(find.text('Kolom B'), findsOneWidget);
      expect(find.text('A1'), findsOneWidget);
      expect(find.text('Total Baris: 2'), findsOneWidget);
    });

    testWidgets('AppEmptyState displays title, description and button', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Data Kosong',
              description: 'Belum ada data tersedia',
              actionLabel: 'Segarkan',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Data Kosong'), findsOneWidget);
      expect(find.text('Belum ada data tersedia'), findsOneWidget);
      await tester.tap(find.text('Segarkan'));
      expect(tapped, isTrue);
    });

    testWidgets('AppDrawer highlights active route properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(currentRoute: '/krs'),
            body: Text('Home Content'),
          ),
        ),
      );

      final ScaffoldState state = tester.firstState(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();

      // Check drawer menu items exist
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('KRS'), findsOneWidget);
      expect(find.text('Pengajuan Studi'), findsOneWidget);
      expect(find.text('KHS'), findsOneWidget);
      expect(find.text('Keluar Akun'), findsOneWidget);
    });
  });

  group('KRS and KHS Pages Navigation, Tabs, & Responsive Tests', () {
    testWidgets('KrsPage renders back button, hamburger, and shortened tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KrsPage(npm: '12523030'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tombol kembali (arrow_back) ada di kiri AppBar
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Hamburger menu ada di actions AppBar
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

      // TabBar dengan label yang tidak terpotong
      expect(find.text('Data KRS'), findsOneWidget);
      expect(find.text('Pengajuan'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
    });

    testWidgets('PengajuanStudiPage navigates to Form tab directly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PengajuanStudiPage(npm: '12523030', initialTab: 1),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Formulir Pengajuan Studi'), findsOneWidget);
      expect(find.text('Kirim Pengajuan Studi'), findsOneWidget);
    });

    testWidgets('KhsPage renders back button, hamburger, summary metrics and grade table', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KhsPage(
            npm: '12523030',
            nilaiServiceOverride: _TestNilaiService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tombol kembali dan hamburger
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

      expect(find.text('Kartu Hasil Studi (KHS)'), findsOneWidget);
      expect(find.text('Tahun Akademik'), findsOneWidget);
      expect(find.text('Semester'), findsOneWidget);
      expect(find.text('IP Semester (IPS)'), findsOneWidget);
      expect(find.text('IP Kumulatif (IPK)'), findsOneWidget);
      expect(find.text('4.00'), findsOneWidget);
      expect(find.text('3.90'), findsOneWidget);
    });

    testWidgets('No RenderFlex overflow on small screen widths (320px, 360px, 411px)', (WidgetTester tester) async {
      for (final double width in <double>[320.0, 360.0, 411.0]) {
        tester.view.physicalSize = Size(width * 2.0, 800.0 * 2.0);
        tester.view.devicePixelRatio = 2.0;

        // 1. Test KRS Page Tab 0 (Data KRS)
        await tester.pumpWidget(
          const MaterialApp(
            home: KrsPage(npm: '12523030', initialTabIndex: 0),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: 'KRS Page Tab 0 overflow on $width px');

        // 2. Test KRS Page Tab 1 (Form Pengajuan Studi)
        await tester.pumpWidget(
          const MaterialApp(
            home: KrsPage(npm: '12523030', initialTabIndex: 1),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: 'KRS Page Tab 1 Form overflow on $width px');

        // 3. Test KHS Page
        await tester.pumpWidget(
          MaterialApp(
            home: KhsPage(
              npm: '12523030',
              nilaiServiceOverride: _TestNilaiService(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'KHS Page overflow on $width px');
      }

      // Reset tester window view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
