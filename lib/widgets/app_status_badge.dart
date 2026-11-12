import 'package:flutter/material.dart';

import '../theme.dart';

enum StatusBadgeVariant {
  success,
  warning,
  danger,
  neutral,
}

/// Komponen StatusBadge reusable untuk status KRS dan Pengajuan Studi.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.variant,
    this.icon,
  });

  final String label;
  final StatusBadgeVariant? variant;
  final IconData? icon;

  /// Pabrik status badge otomatis berdasarkan string atau integer status
  factory AppStatusBadge.fromStatus(dynamic status, {String? customLabel}) {
    final String s = status?.toString().trim().toLowerCase() ?? '';

    if (s == '1' || s == 'aktif' || s == 'disetujui' || s == 'approved') {
      return AppStatusBadge(
        label: customLabel ?? (s == '1' ? 'Aktif' : 'Disetujui'),
        variant: StatusBadgeVariant.success,
        icon: Icons.check_circle_outline,
      );
    } else if (s == 'pending' || s == 'menunggu' || s == 'diproses') {
      return AppStatusBadge(
        label: customLabel ?? 'Pending',
        variant: StatusBadgeVariant.warning,
        icon: Icons.access_time_rounded,
      );
    } else if (s == '0' || s == 'tidak aktif' || s == 'ditolak' || s == 'rejected') {
      return AppStatusBadge(
        label: customLabel ?? (s == '0' ? 'Tidak Aktif' : 'Ditolak'),
        variant: StatusBadgeVariant.danger,
        icon: Icons.cancel_outlined,
      );
    }

    return AppStatusBadge(
      label: customLabel ?? status?.toString() ?? '-',
      variant: StatusBadgeVariant.neutral,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant ?? StatusBadgeVariant.neutral) {
      case StatusBadgeVariant.success:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        border = const Color(0xFFA7F3D0);
      case StatusBadgeVariant.warning:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        border = const Color(0xFFFDE68A);
      case StatusBadgeVariant.danger:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        border = const Color(0xFFFECACA);
      case StatusBadgeVariant.neutral:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        border = const Color(0xFFE2E8F0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppText.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
