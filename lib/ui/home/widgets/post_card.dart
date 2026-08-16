import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';
import 'package:paw_around/utils/date_utils.dart';

class PostCard extends StatelessWidget {
  final LostFoundPost post;
  final double? distanceKm;
  final VoidCallback? onTap;
  final bool isFromYourPosts;

  const PostCard({
    super.key,
    required this.post,
    this.distanceKm,
    this.onTap,
    this.isFromYourPosts = false,
  });

  bool get _isOwner => post.userId == sl<AuthRepository>().currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ScaleButton(
        onPressed: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: smoothDecoration(
            cornerRadius: 24,
            color: AppColors.white,
            side: const BorderSide(color: AppColors.border),
            shadows: [
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.051),
                  blurRadius: 7,
                  offset: const Offset(0, 3)),
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.039),
                  blurRadius: 13,
                  offset: const Offset(0, 13)),
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.031),
                  blurRadius: 18,
                  offset: const Offset(0, 30)),
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.012),
                  blurRadius: 21,
                  offset: const Offset(0, 54)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 4),
                    _buildSubtitle(),
                    if (post.petDescription.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDescription(),
                    ],
                    const SizedBox(height: 14),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'post-image-${post.id}',
      child: Stack(
        children: [
          Container(
            height: 182,
            clipBehavior: Clip.antiAlias,
            decoration: smoothDecoration(cornerRadius: 20),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            width: double.infinity,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildPostImage()),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _buildStatusBadge(),
          ),
          if (_isOwner && !isFromYourPosts)
            Positioned(
              top: 12,
              right: 12,
              child: _buildYourPostBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    if (post.imagePath == null || post.imagePath!.isEmpty) {
      return _buildPlaceholder();
    }
    if (post.imagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: post.imagePath!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.iconBgLight,
          child: const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.iconBgLight,
      child: const Center(
          child: Icon(Icons.pets, size: 56, color: AppColors.primary)),
    );
  }

  Widget _buildStatusBadge() {
    final isLost = post.type == PostType.lost;
    final color = isLost ? AppColors.error : AppColors.success;
    final typeLabel = isLost ? AppStrings.missing : AppStrings.found;
    final timeLabel = AppDateUtils.getRelativeTimeShort(post.createdAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: smoothDecoration(
        color: color,
        borderRadius: const SmoothBorderRadius.only(
          topLeft: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
          bottomRight: SmoothRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$typeLabel: ',
              style: AppTextStyles.interMediumStyle500(
                  fontSize: 12, fontColor: AppColors.white),
            ),
            TextSpan(
              text: timeLabel,
              style: AppTextStyles.interBoldStyle700(
                  fontSize: 12, fontColor: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourPostBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(AppStrings.yourPost,
          style: AppTextStyles.interBoldStyle700(
              fontSize: 12, fontColor: AppColors.textPrimary)),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            post.petName,
            style: AppTextStyles.interBoldStyle700(
                fontSize: 16, fontColor: AppColors.grey1100),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.near_me_outlined, size: 24, color: AppColors.grey1100),
      ],
    );
  }

  Widget _buildSubtitle() {
    final parts = <String>[];
    if (post.breed.isNotEmpty) parts.add(post.breed);
    if (post.color.isNotEmpty) parts.add(post.color);
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' · '),
      style: AppTextStyles.interMediumStyle500(
          fontSize: 14, fontColor: AppColors.grey600),
    );
  }

  Widget _buildDescription() {
    return Text(
      post.petDescription,
      style: AppTextStyles.interMediumStyle500(
          fontSize: 16, fontColor: AppColors.grey1100),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(Icons.my_location, size: 20, color: AppColors.grey600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            post.locationName,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distanceKm != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${distanceKm!.toStringAsFixed(1)} ${AppStrings.kmAway}',
              style: AppTextStyles.interMediumStyle500(
                  fontSize: 11, fontColor: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}
