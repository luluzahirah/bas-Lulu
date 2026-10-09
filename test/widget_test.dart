import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bas/main.dart';

void main() {
  testWidgets('Login mengarah ke Student App dengan 4 tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Masuk ke akun Anda'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '1234567890');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Student App'), findsOneWidget);
    expect(find.text('Welcome My Student Apps'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('News'), findsOneWidget);
  });
}
