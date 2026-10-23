import 'dart:async';

import 'package:flutter/material.dart';

import 'home.dart';
import 'info.dart';
import 'news.dart';
import 'profile.dart';
import 'theme.dart';

/// Memberi akses toast ke seluruh tab.
class ToastScope extends InheritedWidget {
  const ToastScope({
    super.key,
    required this.showToast,
    required super.child,
  });

  final void Function(String message) showToast;

  static ToastScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToastScope>()!;
  }

  @override
  bool updateShouldNotify(ToastScope oldWidget) => false;
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;
  String? _toast;
  Timer? _toastTimer;

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
  ];

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    setState(() => _toast = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _select(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ToastScope(
        showToast: _showToast,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
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
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
            _buildToast(),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _buildNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToast() {
    final bool show = _toast != null;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 92,
      child: IgnorePointer(
        child: Center(
          child: AnimatedSlide(
            offset: show ? Offset.zero : const Offset(0, 0.6),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _toast ?? '',
                  style: AppText.body.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
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
          const double activeWeight = 2.5;
          const double totalWeight = activeWeight + 3;
          final double slot = constraints.maxWidth / totalWeight;
          return Row(
            children: <Widget>[
              for (int i = 0; i < _tabs.length; i++)
                _navItem(
                  i,
                  _tabs[i].$1,
                  _tabs[i].$2,
                  _selectedIndex == i ? slot * activeWeight : slot,
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
          duration: const Duration(milliseconds: 500),
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
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                child: AnimatedScale(
                  scale: active ? 1.15 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 22,
                    color: active ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
              if (active) ...<Widget>[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: AppText.navLabel.copyWith(color: Colors.white),
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
