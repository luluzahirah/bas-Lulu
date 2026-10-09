import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semua token desain BAS. Dilarang menulis warna/ukuran acak di widget.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF0B1F4B);
  static const Color navy2 = Color(0xFF16306E);
  static const Color royal = Color(0xFF2447A8);
  static const Color bg = Color(0xFFEEF1F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF5B6786);
  static const Color muted = Color(0xFF8A94A8);
  static const Color periwinkle = Color(0xFF9DB8FF);
  static const Color border = Color(0xFFC9D3EA);
  static const Color dot = Color(0xFFFF5C7A);

  static const Color headerSubtitle = Color(0xFFB9C9F5);
  static const Color focusRing = Color(0xFFE4EAF8);

  /// Pastel untuk latar tile/tag/avatar. Siklus `pastelAt(i)`.
  static const List<Color> pastel = <Color>[
    Color(0xFFD6E4FF), // biru
    Color(0xFFE6DFFF), // ungu
    Color(0xFFD5F2E7), // mint
    Color(0xFFFFE4D3), // peach
    Color(0xFFFFDDE8), // pink
    Color(0xFFFFF1C2), // kuning
  ];

  static Color pastelAt(int index) => pastel[index % pastel.length];

  static const List<Color> g1 = <Color>[Color(0xFF1E4FD8), Color(0xFF5B8BFF)];
  static const List<Color> g2 = <Color>[Color(0xFF5B3FD1), Color(0xFF9A7BFF)];
  static const List<Color> g3 = <Color>[Color(0xFF0E8A8C), Color(0xFF3CC8B4)];
  static const List<Color> g4 = <Color>[Color(0xFFE4572E), Color(0xFFFF9A6B)];
  static const List<Color> hero = <Color>[Color(0xFF0B1F4B), Color(0xFF1E3A8A)];
  static const List<Color> overview = <Color>[
    Color(0xFFD6E4FF),
    Color(0xFFE6DFFF),
  ];

  static const List<Color> headerDecor = <Color>[
    Color(0xFF8B5CF6),
    Color(0xFF2DD4BF),
    Color(0xFFFF9A6B),
  ];
}

/// Radius dan jarak.
class AppRadius {
  AppRadius._();

  static const double bigCard = 26;
  static const double gradientCard = 22;
  static const double listRow = 20;
  static const double sheetTop = 28;
  static const double loginSheet = 34;
  static const double pill = 23;
  static const double button = 28;
  static const double bottomNav = 32;

  static const double pagePadding = 18;
  static const double cardGap = 14;
}

/// Tipografi Poppins.
class AppText {
  AppText._();

  static TextStyle _poppins({
    required double size,
    required FontWeight weight,
    Color color = AppColors.navy,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static final TextStyle loginTitle = _poppins(
    size: 28,
    weight: FontWeight.w600,
    letterSpacing: 1,
  );
  static final TextStyle headerTitle = _poppins(
    size: 26,
    weight: FontWeight.w600,
    height: 1.25,
  );
  static final TextStyle sheetTitle = _poppins(
    size: 19,
    weight: FontWeight.w600,
  );
  static final TextStyle name = _poppins(size: 18, weight: FontWeight.w600);
  static final TextStyle nameSmall = _poppins(size: 17, weight: FontWeight.w600);
  static final TextStyle cardTitle = _poppins(size: 14, weight: FontWeight.w600);
  static final TextStyle listTitle = _poppins(size: 13, weight: FontWeight.w500);
  static final TextStyle body = _poppins(size: 12, weight: FontWeight.w400);
  static final TextStyle caption = _poppins(size: 11, weight: FontWeight.w400);
  static final TextStyle bigNumber = _poppins(size: 46, weight: FontWeight.w600);
  static final TextStyle navLabel = _poppins(size: 13, weight: FontWeight.w500);
}

/// Tema global aplikasi.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      surface: AppColors.card,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
    );
  }
}
