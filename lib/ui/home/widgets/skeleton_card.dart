import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';

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
            decoration: smoothDecoration(
              cornerRadius: 4,
              color: AppColors.progressBarBg,
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

/// Skeleton for the app bar (matches DashboardAppBar styling)
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
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Avatar skeleton
            Container(
              width: 48,
              height: 48,
              decoration: smoothDecoration(
                cornerRadius: 14,
                color: AppColors.progressBarBg,
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
                    decoration: smoothDecoration(
                      cornerRadius: 4,
                      color: AppColors.progressBarBg,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 70,
                    decoration: smoothDecoration(
                      cornerRadius: 4,
                      color: AppColors.progressBarBg,
                    ),
                  ),
                ],
              ),
            ),
            // Action button skeleton
            Container(
              width: 44,
              height: 44,
              decoration: smoothDecoration(
                cornerRadius: 14,
                color: AppColors.progressBarBg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a single post card (matches PostCard layout)
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space8,
      ),
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusMD,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const SkeletonCard(height: 150, borderRadius: 16),
          Padding(
            padding: AppEdgeInsets.cardPaddingSmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 120, height: 20),
                    _buildShimmerBox(width: 60, height: 16),
                  ],
                ),
                AppSpacing.vertical8,
                // Description lines
                _buildShimmerBox(width: double.infinity, height: 14),
                AppSpacing.vertical6,
                _buildShimmerBox(width: 200, height: 14),
                AppSpacing.vertical10,
                // Footer
                Row(
                  children: [
                    _buildShimmerBox(width: 14, height: 14, circular: true),
                    AppSpacing.horizontal4,
                    _buildShimmerBox(width: 80, height: 12),
                  ],
                ),
                AppSpacing.vertical4,
                Row(
                  children: [
                    _buildShimmerBox(width: 14, height: 14, circular: true),
                    AppSpacing.horizontal4,
                    Expanded(child: _buildShimmerBox(width: 150, height: 12)),
                    _buildShimmerBox(width: 40, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    double? width,
    bool circular = false,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: smoothDecoration(
        cornerRadius: circular ? height / 2 : 4,
        color: AppColors.progressBarBg,
      ),
    );
  }
}

/// Skeleton for community screen (list of post cards)
class CommunitySkeleton extends StatelessWidget {
  final int itemCount;

  const CommunitySkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppConstants.space8),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => const PostCardSkeleton(),
        ),
      ),
    );
  }
}

/// Skeleton for a generic list item with avatar
class ListItemSkeleton extends StatelessWidget {
  final double avatarSize;
  final bool showSubtitle;

  const ListItemSkeleton({
    super.key,
    this.avatarSize = 48,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space12,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              color: AppColors.progressBarBg,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.horizontal12,
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.progressBarBg,
                  ),
                ),
                if (showSubtitle) ...[
                  AppSpacing.vertical6,
                  Container(
                    height: 12,
                    width: 80,
                    decoration: smoothDecoration(
                      cornerRadius: 4,
                      color: AppColors.progressBarBg,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.progressBarBg,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the profile screen
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: AppEdgeInsets.allMedium,
      child: Column(
        children: [
          // Profile header skeleton
          _buildProfileHeaderSkeleton(),
          AppSpacing.vertical20,
          // Pets section skeleton
          _buildPetsSectionSkeleton(),
          AppSpacing.vertical20,
          // Account section skeleton
          _buildAccountSectionSkeleton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderSkeleton() {
    return Container(
      padding: AppEdgeInsets.cardPadding,
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusXL,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.progressBarBg,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.horizontal16,
          // Name and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 140,
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.progressBarBg,
                  ),
                ),
                AppSpacing.vertical8,
                Container(
                  height: 14,
                  width: 100,
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.progressBarBg,
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.progressBarBg,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsSectionSkeleton() {
    return Container(
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusXL,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              height: 16,
              width: 80,
              decoration: smoothDecoration(
                cornerRadius: 4,
                color: AppColors.progressBarBg,
              ),
            ),
          ),
          // Pet items
          const ListItemSkeleton(avatarSize: 60),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const ListItemSkeleton(avatarSize: 60),
        ],
      ),
    );
  }

  Widget _buildAccountSectionSkeleton() {
    return Container(
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusXL,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(
          4,
          (index) => Column(
            children: [
              const ListItemSkeleton(avatarSize: 40, showSubtitle: false),
              if (index < 3) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          ),
        ),
      ),
    );
  }
}
