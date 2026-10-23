import 'package:flutter/material.dart';

import 'pages/auth_page.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAS Student App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthPage(),
    );
  }
}
