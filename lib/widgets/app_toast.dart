import 'package:flutter/material.dart';

import '../theme.dart';

/// Utilitas Toast / SnackBar reusable bergaya modern dengan ikon dan tema BAS.
class AppToast {
  AppToast._();

  /// Menampilkan toast sukses (hijau)
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      bgColor: const Color(0xFF0F766E),
    );
  }

  /// Menampilkan toast gagal / error (merah)
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      bgColor: const Color(0xFFB91C1C),
    );
  }

  /// Menampilkan toast info (biru BAS)
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      bgColor: AppColors.navy,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color bgColor,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        elevation: 6,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppText.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
