import 'package:flutter/material.dart';

import 'akademik.dart';
import 'api/auth_api.dart';
import 'home.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'profile.dart';
import 'theme.dart';

/// Memberi akses navigasi antar-tab dari dalam halaman manapun.
class NavScope extends InheritedWidget {
  const NavScope({
    super.key,
    required this.goToTab,
    required this.goToAkademik,
    required super.child,
  });

  final void Function(int tabIndex) goToTab;
  final void Function(int akademikIndex) goToAkademik;

  static NavScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavScope>();
  }

  static NavScope of(BuildContext context) {
    final NavScope? scope = maybeOf(context);
    assert(scope != null, 'NavScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(NavScope oldWidget) => false;
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.user});

  final UserAccount user;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;

<<<<<<< HEAD
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    InfoScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  static const List<(IconData, String)> _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.info_outline, 'Info'),
    (Icons.article_outlined, 'News'),
    (Icons.person_outline, 'Profile'),
=======
  // Pending index untuk langsung buka submenu Akademik
  int? _pendingAkademikIndex;

  static const List<(IconData, String)> _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Beranda'),
    (Icons.calendar_month_outlined, 'Jadwal'),
    (Icons.school_outlined, 'Akademik'),
    (Icons.campaign_outlined, 'Pengumuman'),
    (Icons.person_outline, 'Profil'),
>>>>>>> f8fc6fe (Revisi)
  ];

  void _goToTab(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _pendingAkademikIndex = null;
      });
    }
  }

  void _goToAkademik(int akademikIndex) {
    setState(() {
      _selectedIndex = 2;
      _pendingAkademikIndex = akademikIndex;
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(user: widget.user);
      case 1:
        return const JadwalScreen();
      case 2:
        final int? ai = _pendingAkademikIndex;
        if (_pendingAkademikIndex != null) {
          _pendingAkademikIndex = null;
        }
        return AkademikScreen(initialIndex: ai, user: widget.user);
      case 3:
        return const PengumumanScreen();
      case 4:
        return ProfileScreen(user: widget.user);
      default:
        return HomeScreen(user: widget.user);
    }
  }

  void _select(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _pendingAkademikIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavScope(
      goToTab: _goToTab,
      goToAkademik: _goToAkademik,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final CurvedAnimation curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: _buildPage(_selectedIndex),
                ),
              ),
            ),
            Positioned(left: 14, right: 14, bottom: 14, child: _buildNav()),
          ],
        ),
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.bottomNav),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double activeWeight = 2.4;
          const double inactiveWeight = 1.0;
          const double totalWeight = activeWeight + 4 * inactiveWeight;
          final double slot = constraints.maxWidth / totalWeight;
          return Row(
            children: <Widget>[
              for (int i = 0; i < _tabs.length; i++)
                _navItem(
                  i,
                  _tabs[i].$1,
                  _tabs[i].$2,
                  _selectedIndex == i
                      ? slot * activeWeight
                      : slot * inactiveWeight,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, double width) {
    final bool active = _selectedIndex == index;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          width: width,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: active ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedSlide(
                offset: Offset(0, active ? -5 / 22 : 0),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                child: AnimatedScale(
                  scale: active ? 1.15 : 1,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 22,
                    color: active ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
              if (active) ...<Widget>[
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: AppText.navLabel.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
