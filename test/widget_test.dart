import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bas/api/auth_api.dart';
import 'package:bas/pages/auth_page.dart';
import 'package:bas/welcome.dart';

class _FakeAuthApi extends AuthApi {
  @override
  Future<List<UserAccount>> fetchUsers() async {
    return <UserAccount>[
      UserAccount(
        npm: '12523030',
        passwordSha1: sha1Hex('testpass'),
        name: 'Mahasiswa Demo',
        prodi: 'Prodi Demo',
        fakultas: 'Fakultas Demo',
        semester: 1,
        ipk: 0,
        sks: 0,
      ),
    ];
  }
}

void main() {
  testWidgets('Login berhasil membuka Student App', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: AuthPage(authApi: _FakeAuthApi())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, '12523030');
    await tester.enterText(find.byType(TextField).last, 'testpass');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.pump();
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
