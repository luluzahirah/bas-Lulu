import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const DarkHeader(
            title: 'Info kampus',
            subtitle: 'yang kamu butuhkan',
            child: PillSearch(hint: 'Cari info, layanan...'),
          ),
          SheetBody(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
            child: Column(
              children: <Widget>[
                Staggered(index: 0, child: _buildGrid()),
                const SizedBox(height: 14),
                Staggered(
                  index: 1,
                  child: ListRow(
                    leading: pastelTile(Icons.apps_rounded, 2),
                    body: _rowText(
                      'Nama aplikasi',
                      'BAS (Boash Application System)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Staggered(
                  index: 2,
                  child: ListRow(
                    leading: pastelTile(Icons.info_outline, 3),
                    body: _rowText('Versi', '1.0.0'),
                  ),
                ),
                const SizedBox(height: 10),
                Staggered(
                  index: 3,
                  child: ListRow(
                    leading: pastelTile(Icons.menu_book_outlined, 4),
                    body: _rowText(
                      'Deskripsi',
                      'Aplikasi mahasiswa dengan tab Home, Info, Profile, dan News.',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Staggered(index: 4, child: _buildBanner()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: AppText.listTitle),
        Text(
          value,
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: GradientCard(
                colors: AppColors.g1,
                icon: Icons.menu_book_outlined,
                title: 'Akademik',
                subtitle: 'Jadwal dan KRS',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientCard(
                colors: AppColors.g2,
                icon: Icons.workspace_premium_outlined,
                title: 'Beasiswa',
                subtitle: 'Program terbuka',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: GradientCard(
                colors: AppColors.g3,
                icon: Icons.calendar_today_outlined,
                title: 'Kalender',
                subtitle: 'Agenda semester',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientCard(
                colors: AppColors.g4,
                icon: Icons.location_on_outlined,
                title: 'Peta kampus',
                subtitle: 'Gedung dan ruang',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.overview,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 56, height: 28, child: _AvatarStack()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Tanya admin kampus', style: AppText.listTitle),
                Text(
                  'Respon dalam 1 jam',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const ArrowCircle(
            size: 38,
            background: AppColors.navy,
            iconColor: Colors.white,
            tooltip: 'Tanya admin',
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(left: 0, child: _letter('A', AppColors.pastelAt(0))),
        Positioned(left: 14, child: _letter('R', AppColors.pastelAt(3))),
        Positioned(left: 28, child: _letter('D', AppColors.pastelAt(2))),
      ],
    );
  }

  Widget _letter(String letter, Color color) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        letter,
        style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
