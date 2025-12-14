import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/utils/date_utils.dart';

class PostCard extends StatelessWidget {
  final LostFoundPost post;
  final double? distanceKm;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.distanceKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildDescription(),
                  const SizedBox(height: 8),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: _buildPostImage(),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _buildTypeBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    if (post.imagePath == null || post.imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if it's a network URL
    if (post.imagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: post.imagePath!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Icon(Icons.pets, size: 48, color: AppColors.textLight),
    );
  }

  Widget _buildTypeBadge() {
    final isLost = post.type == PostType.lost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLost ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isLost ? AppStrings.lost : AppStrings.found,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            post.petName,
            style: AppTextStyles.cardTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distanceKm != null)
          Text(
            '${distanceKm!.toStringAsFixed(1)} ${AppStrings.kmAway}',
            style: AppTextStyles.cardSubtitle,
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.breed.isNotEmpty)
          Text(
            '${post.breed} • ${post.color}',
            style: AppTextStyles.cardSubtitle,
          ),
        const SizedBox(height: 4),
        Text(
          post.petDescription,
          style: AppTextStyles.bodyText.copyWith(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              post.userName,
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                post.locationName,
                style: AppTextStyles.cardSubtitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              AppDateUtils.getRelativeTimeShort(post.createdAt),
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      ],
    );
  }
}
