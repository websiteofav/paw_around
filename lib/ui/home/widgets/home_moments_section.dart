import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';

class HomeMomentsSection extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomeMomentsSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetMomentsBloc, PetMomentsState>(
      builder: (context, state) {
        if (state is! PetMomentsLoaded || state.moments.isEmpty) {
          return const SizedBox.shrink();
        }
        final moments = state.moments.take(6).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.momentsFromPawCircle,
                    style: AppTextStyles.boldStyle700(
                        fontSize: 18, fontColor: AppColors.grey1000)),
                GestureDetector(
                  onTap: onSeeAll,
                  child: Row(children: [
                    Text(AppStrings.seeAll,
                        style: AppTextStyles.interBoldStyle700(
                            fontSize: 16, fontColor: AppColors.secondaryCTA)),
                    const Icon(Icons.chevron_right,
                        color: AppColors.secondaryCTA, size: 18),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 312,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: moments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _MomentThumbnail(moment: moments[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MomentThumbnail extends StatelessWidget {
  final PetMoment moment;
  const _MomentThumbnail({required this.moment});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ${AppStrings.ago}';
    if (diff.inHours >= 1) return '${diff.inHours}h ${AppStrings.ago}';
    return '${diff.inMinutes}m ${AppStrings.ago}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: smoothDecoration(
        cornerRadius: 16,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.grey100),
        shadows: [
          BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          ClipSmoothRect(
            radius: AppSmoothRadius.custom(12),
            child: moment.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: moment.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                        height: 160,
                        color: AppColors.surface,
                        child: const Center(
                            child: Icon(Icons.pets,
                                color: AppColors.textLight, size: 36))))
                : Container(
                    height: 160,
                    color: AppColors.surface,
                    child: const Center(
                        child: Icon(Icons.pets,
                            color: AppColors.textLight, size: 36))),
          ),
          const SizedBox(height: 10),
          // User row
          Row(
            children: [
              const Icon(Icons.account_circle,
                  size: 18, color: AppColors.grey600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(moment.userName,
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 12, fontColor: AppColors.grey600),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(_timeAgo(moment.createdAt),
                  style: AppTextStyles.interRegularStyle400(
                      fontSize: 12, fontColor: AppColors.grey600)),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          if (moment.petName.isNotEmpty)
            Text(moment.petName,
                style: AppTextStyles.interBoldStyle700(
                    fontSize: 14, fontColor: AppColors.grey1000),
                overflow: TextOverflow.ellipsis),
          // Caption
          if (moment.caption.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(moment.caption,
                style: AppTextStyles.interRegularStyle400(
                    fontSize: 12, fontColor: AppColors.grey600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.grey100, height: 1),
          // Likes & comments
          const SizedBox(height: 12),

          Row(children: [
            SvgPicture.asset(AppIcons.heartIcon,
                colorFilter: const ColorFilter.mode(
                    AppColors.grey1000, BlendMode.srcIn)),
            const SizedBox(width: 4),
            Text(moment.likeCount.toString(),
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 12, fontColor: AppColors.grey1000)),
            const SizedBox(width: 16),
            SvgPicture.asset(AppIcons.commentIcon,
                colorFilter: const ColorFilter.mode(
                    AppColors.grey1000, BlendMode.srcIn)),
            const SizedBox(width: 4),
            Text(moment.commentCount.toString(),
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 12, fontColor: AppColors.grey1000)),
          ]),
        ],
      ),
    );
  }
}
