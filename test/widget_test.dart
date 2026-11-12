import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bas/api/auth_api.dart';
import 'package:bas/models/nilai_model.dart';
import 'package:bas/pages/auth_page.dart';
import 'package:bas/pages/home_page.dart';
import 'package:bas/services/nilai_service.dart';
import 'package:bas/welcome.dart';

class _FakeAuthApi extends AuthApi {
  @override
  Future<List<UserAccount>> fetchUsers() async {
    return <UserAccount>[
      UserAccount(
        npm: '12523030',
        passwordSha1: sha1Hex('123456'),
        name: 'Sofi Putri Rahayu',
        loginName: 'Sofi Putri Rahayu',
        prodi: 'Teknologi Rekayasa Multimedia',
        fakultas: 'Teknik',
        semester: 5,
        ipk: 3.8,
        sks: 96,
      ),
    ];
  }
}

class _FakeNilaiService extends NilaiService {
  @override
  Future<List<Nilai>> fetchNilai(String npm) async {
    if (npm == '12523030') {
      return const <Nilai>[
        Nilai(
          id: 162801,
          kdMatkul: 'GC327',
          npm: '12523030',
          uas: 70,
          uts: 75,
          quis: 72,
          tugas: 80,
          hadir: 100,
          na: 79.3,
          hm: 'B+',
          am: 3.5,
          mutu: 10.5,
          nip: 'LU0512',
          thnAkademik: '2023/2024',
          semester: 1,
        ),
      ];
    }
    throw NpmNotFoundException(npm);
  }
}

void main() {
  testWidgets('Login berhasil dengan NPM 12523030 dan password default 123456', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: AuthPage(
            authApi: _FakeAuthApi(),
            nilaiService: _FakeNilaiService(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, '12523030');
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.pump();
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('NPM acak (99999999) menampilkan pesan NPM tidak terdaftar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: AuthPage(
            authApi: _FakeAuthApi(),
            nilaiService: _FakeNilaiService(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, '99999999');
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('NPM tidak terdaftar'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
  });

  testWidgets('Format email menampilkan pesan login email belum tersedia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: AuthPage(
            authApi: _FakeAuthApi(),
            nilaiService: _FakeNilaiService(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(
      find.byType(TextField).first,
      'mahasiswa@kampus.ac.id',
    );
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Login email belum tersedia, gunakan NPM'),
      findsOneWidget,
    );
    expect(find.byType(WelcomeScreen), findsNothing);
  });

  testWidgets('Kata sandi salah menampilkan pesan error Kata sandi salah', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: AuthPage(
            authApi: _FakeAuthApi(),
            nilaiService: _FakeNilaiService(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, '12523030');
    await tester.enterText(find.byType(TextField).last, 'wrong_pass');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Kata sandi salah'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
  });

  testWidgets(
    'UI Login: tombol Email dan Google ada, Siakad tidak ada, Akun Demo tidak ada, QR Attendance tidak ada',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: AuthPage(
              authApi: _FakeAuthApi(),
              nilaiService: _FakeNilaiService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Kartu Akun demo & Link QR Attendance hilang
      expect(find.text('Akun Demo (Siap Pakai)'), findsNothing);
      expect(find.text('Gunakan Akun Demo'), findsNothing);
      expect(
        find.text('Buka Aplikasi QR Attendance (Pertemuan 6)'),
        findsNothing,
      );

      // Tombol Siakad TIDAK ADA, diganti Email dan Google
      expect(find.text('Siakad'), findsNothing);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);

      // Elemen-elemen login Edlink BAS
      expect(find.text('Masuk ke BAS'), findsOneWidget);
      expect(find.text('Atau'), findsOneWidget);
      expect(find.text('NPM / Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Lupa kata sandi'), findsOneWidget);
      expect(find.text('Copyright © 2026 BAS'), findsOneWidget);
    },
  );

  testWidgets('Responsif: tidak ada overflow pada lebar 360, 390, dan 430', (
    WidgetTester tester,
  ) async {
    const List<double> widths = <double>[360, 390, 430];
    for (final double width in widths) {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 740),
            disableAnimations: true,
          ),
          child: MaterialApp(
            home: AuthPage(
              authApi: _FakeAuthApi(),
              nilaiService: _FakeNilaiService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('HomePage QR Attendance menampilkan judul dan tombol Scan QR', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();

    expect(find.text('QR Attendance'), findsWidgets);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Buka BAS Student App'), findsOneWidget);
  });
}
