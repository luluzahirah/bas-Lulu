import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'pages/akademik/khs_page.dart';
import 'pages/akademik/krs_page.dart';
import 'pages/akademik/pengajuan_studi_page.dart';
import 'pages/home_page.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialHome});

  final Widget? initialHome;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAS Student App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: initialHome ?? const HomePage(),
      routes: <String, WidgetBuilder>{
        '/krs': (BuildContext context) => const KrsPage(),
        '/khs': (BuildContext context) => const KhsPage(),
        '/pengajuan-studi': (BuildContext context) =>
            const PengajuanStudiPage(),
      },
    );
  }
}
