import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

/// Skeleton loader for cards with shimmer effect
class SkeletonCard extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 180,
    this.width,
    this.borderRadius = 24,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppColors.progressBarBg,
                AppColors.progressBarBg.withValues(alpha: 0.5),
                AppColors.progressBarBg,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for the home screen content
class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary card skeleton
          const SkeletonCard(height: 200),
          const SizedBox(height: 16),

          // Secondary card skeleton
          const SkeletonCard(height: 140),
          const SizedBox(height: 12),

          // Third card skeleton
          const SkeletonCard(height: 140),
          const SizedBox(height: 16),

          // Summary skeleton
          const SkeletonCard(height: 100, borderRadius: 16),
          const SizedBox(height: 24),

          // Section title skeleton
          Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.progressBarBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Lost pets row skeleton
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 100, borderRadius: 16)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonCard(height: 100, borderRadius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the app bar
class AppBarSkeleton extends StatelessWidget {
  const AppBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar skeleton
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.progressBarBg,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(width: 12),
          // Text skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.progressBarBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 14,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.progressBarBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Bell skeleton
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.progressBarBg,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
