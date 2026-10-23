import 'package:flutter/material.dart';

import '../../api/auth_api.dart';
import '../../theme.dart';
import '../../widgets.dart';

class KtmPage extends StatelessWidget {
  const KtmPage({super.key, this.user});

  final UserAccount? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'KTM',
          style: AppText.nameSmall.copyWith(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Simpan KTM',
            onPressed: () => _showSaveDemo(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
        children: <Widget>[
          _buildDemoNotice(),
          const SizedBox(height: 24),
          _KtmCard(user: user),
          const SizedBox(height: 24),
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo — KTM ini menggunakan data yang tersedia dari akun demo. '
              'Bukan kartu mahasiswa resmi yang dikeluarkan institusi.',
              style: AppText.caption.copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GradientButton(
      title: 'Simpan KTM',
      subtitle: 'Download sebagai gambar',
      onTap: () => _showSaveDemo(context),
    );
  }

  void _showSaveDemo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Simpan KTM'),
        content: Text(
          'Pada demo ini, fungsi download KTM belum terhubung ke backend. '
          'Di aplikasi produksi, KTM dapat disimpan sebagai gambar PNG ke galeri.',
          style: AppText.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

class _KtmCard extends StatelessWidget {
  const _KtmCard({this.user});

  final UserAccount? user;

  @override
  Widget build(BuildContext context) {
    final String nama = user?.name ?? 'Nama Mahasiswa';
    final String npm = user?.npm ?? '24903460015';
    final String prodi = user?.prodi ?? 'Teknologi Rekayasa Multimedia';
    final String fakultas = user?.fakultas ?? 'Teknik';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          // Latar KTM
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF0B1F4B),
                  Color(0xFF1E3A8A),
                  Color(0xFF2447A8),
                ],
              ),
            ),
          ),
          // Dekorasi lingkaran
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Konten KTM
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        size: 20,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'BOASH UNIVERSITY',
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Kartu Tanda Mahasiswa',
                          style: AppText.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'AKTIF',
                        style: AppText.caption.copyWith(
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Info mahasiswa
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Avatar
                    Container(
                      width: 68,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            nama,
                            style: AppText.nameSmall.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            npm,
                            style: AppText.body.copyWith(
                              color: AppColors.periwinkle,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            prodi,
                            style: AppText.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Fakultas $fakultas',
                            style: AppText.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barcode placeholder
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.qr_code,
                        size: 16,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(Barcode hanya tersedia di aplikasi resmi)',
                        style: AppText.caption.copyWith(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
