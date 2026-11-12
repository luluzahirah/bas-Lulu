import 'package:flutter/material.dart';

import '../theme.dart';

/// Komponen Shimmer / Loading Skeleton reusable untuk tabel, form, dan list.
class AppLoadingSkeleton extends StatefulWidget {
  const AppLoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  /// Skeleton tampilan tabel data
  static Widget table({int rows = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppLoadingSkeleton(
          height: 44,
          borderRadius: 14,
          width: double.infinity,
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < rows; i++) ...<Widget>[
          AppLoadingSkeleton(
            height: 52,
            borderRadius: 12,
            width: double.infinity,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// Skeleton tampilan kartu / ringkasan
  static Widget card({double height = 110}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const <Widget>[
          AppLoadingSkeleton(width: 140, height: 16),
          AppLoadingSkeleton(width: 220, height: 22),
          AppLoadingSkeleton(width: 90, height: 14),
        ],
      ),
    );
  }

  @override
  State<AppLoadingSkeleton> createState() => _AppLoadingSkeletonState();
}

class _AppLoadingSkeletonState extends State<AppLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _animation = Tween<double>(begin: 0.35, end: 0.85)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1).withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
