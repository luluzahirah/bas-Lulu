import 'package:flutter/material.dart';

import 'krs_page.dart';

/// Halaman pembuka langsung fitur Pengajuan Studi (Tab Form/Riwayat Pengajuan)
/// untuk routing direct `/pengajuan-studi` dan menu sidebar.
class PengajuanStudiPage extends StatelessWidget {
  const PengajuanStudiPage({
    super.key,
    this.npm,
    this.initialTab = 1,
  });

  final String? npm;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return KrsPage(
      npm: npm,
      initialTabIndex: initialTab,
    );
  }
}
