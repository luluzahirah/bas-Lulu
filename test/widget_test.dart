import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bas/api/auth_api.dart';
import 'package:bas/pages/auth_page.dart';
import 'package:bas/welcome.dart';

class _FakeAuthApi extends AuthApi {
  @override
  Future<Map<String, dynamic>> fetchRandomUser() async {
    return <String, dynamic>{
      'login': <String, dynamic>{
        'username': 'testuser',
        'password': 'testpass',
      },
    };
  }
}

void main() {
  testWidgets('Login berhasil membuka Student App', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AuthPage(authApi: _FakeAuthApi())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Username: testuser'), findsOneWidget);
    expect(find.text('Password: testpass'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'testuser');
    await tester.enterText(find.byType(TextField).last, 'testpass');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
