import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/utils/date_utils.dart';
import 'package:paw_around/utils/share_utils.dart';

class MomentCard extends StatelessWidget {
  final PetMoment moment;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onDelete;

  const MomentCard({
    super.key,
    required this.moment,
    this.onLike,
    this.onComment,
    this.onDelete,
  });

  bool get _isLiked {
    final currentUserId = sl<AuthRepository>().currentUser?.uid;
    if (currentUserId == null) return false;
    return moment.isLikedBy(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: _buildHeader(),
            ),
            _buildImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActions(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  _buildCaption(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.iconBgLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            moment.userName,
            style: AppTextStyles.interBoldStyle700(
                fontSize: 14, fontColor: AppColors.grey1100),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppDateUtils.getRelativeTimeShort(moment.createdAt),
          style: AppTextStyles.interRegularStyle400(
              fontSize: 12, fontColor: AppColors.grey600),
        ),
        if (onDelete != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textSecondary, size: 20),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'delete') onDelete!();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_forever_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.deleteMoment,
                      style: AppTextStyles.mediumStyle500(
                          fontSize: 14, fontColor: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'moment-image-${moment.id}',
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: _buildMomentImage(),
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
      child: const Icon(Icons.pets, size: 48, color: AppColors.textLight),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildLikeButton(),
        const SizedBox(width: 16),
        _buildCommentButton(),
        const Spacer(),
        GestureDetector(
          onTap: () => ShareUtils.shareMoment(moment),
          child: Image.asset(
            AppIcons.shareIcon,
            width: 20,
            height: 20,
            color: AppColors.textSecondary,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: onLike,
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.heartIcon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              _isLiked ? AppColors.error : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            moment.likeCount.toString(),
            style: AppTextStyles.mediumStyle500(
                fontSize: 14, fontColor: AppColors.textSecondary),
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
          SvgPicture.asset(
            AppIcons.commentIcon,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
                AppColors.textSecondary, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Text(
            moment.commentCount.toString(),
            style: AppTextStyles.mediumStyle500(
                fontSize: 14, fontColor: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    if (moment.petName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        moment.petName,
        style: AppTextStyles.semiBoldStyle600(fontSize: 15),
      ),
    );
  }

  Widget _buildCaption() {
    if (moment.caption.isEmpty) return const SizedBox.shrink();
    return Text(
      moment.caption,
      style: AppTextStyles.regularStyle400(
          fontSize: 14, fontColor: AppColors.textSecondary),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
