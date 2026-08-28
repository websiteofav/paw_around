import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/moment_draft.dart';

/// Renders [draft] the way it will look as a posted [MomentCard], using the
/// local file (not yet uploaded) for the photo.
class MomentPreviewCard extends StatelessWidget {
  final MomentDraft draft;
  final String userName;

  const MomentPreviewCard(
      {super.key, required this.draft, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.file(File(draft.imagePath), fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActions(),
                const SizedBox(height: 12),
                if (draft.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(draft.title,
                        style: AppTextStyles.semiBoldStyle600(fontSize: 15)),
                  ),
                if (draft.caption.isNotEmpty)
                  Text(
                    draft.caption,
                    style: AppTextStyles.regularStyle400(
                        fontSize: 14, fontColor: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
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
              color: AppColors.iconBgLight, shape: BoxShape.circle),
          child: const Icon(Icons.pets, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName,
                  style: AppTextStyles.interBoldStyle700(
                      fontSize: 14, fontColor: AppColors.grey1100),
                  overflow: TextOverflow.ellipsis),
              if (draft.locationName.isNotEmpty)
                Text(draft.locationName,
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 12, fontColor: AppColors.grey600),
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(AppStrings.justNow,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 12, fontColor: AppColors.grey600)),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Row(children: [
          SvgPicture.asset(AppIcons.heartIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn)),
          const SizedBox(width: 6),
          Text('0',
              style: AppTextStyles.mediumStyle500(
                  fontSize: 14, fontColor: AppColors.textSecondary)),
        ]),
        const SizedBox(width: 16),
        Row(children: [
          SvgPicture.asset(AppIcons.commentIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn)),
          const SizedBox(width: 6),
          Text('0',
              style: AppTextStyles.mediumStyle500(
                  fontSize: 14, fontColor: AppColors.textSecondary)),
        ]),
        const Spacer(),
        Image.asset(AppIcons.shareIcon,
            width: 20,
            height: 20,
            color: AppColors.textSecondary,
            colorBlendMode: BlendMode.srcIn),
      ],
    );
  }
}
