import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/utils/date_utils.dart';

class MomentCard extends StatelessWidget {
  final PetMoment moment;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const MomentCard({
    super.key,
    required this.moment,
    this.onLike,
    this.onComment,
  });

  bool get _isLiked {
    final currentUserId = sl<AuthRepository>().currentUser?.uid;
    if (currentUserId == null) return false;
    return moment.isLikedBy(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildCaption(),
                const SizedBox(height: 12),
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'moment-image-${moment.id}',
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: _buildMomentImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentImage() {
    if (moment.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: moment.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surface,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Icon(
        Icons.pets,
        size: 48,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (moment.petName.isNotEmpty) ...[
                Text(
                  moment.petName,
                  style: AppTextStyles.semiBoldStyle600(fontSize: 16),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                moment.userName,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          AppDateUtils.getRelativeTimeShort(moment.createdAt),
          style: AppTextStyles.regularStyle400(
            fontSize: 12,
            fontColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCaption() {
    if (moment.caption.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      moment.caption,
      style: AppTextStyles.regularStyle400(fontSize: 14),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildLikeButton(),
        const SizedBox(width: 16),
        _buildCommentButton(),
        const Spacer(),
      ],
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: onLike,
      child: Row(
        children: [
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? AppColors.error : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            moment.likeCount.toString(),
            style: AppTextStyles.mediumStyle500(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: onComment,
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            moment.commentCount.toString(),
            style: AppTextStyles.mediumStyle500(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
