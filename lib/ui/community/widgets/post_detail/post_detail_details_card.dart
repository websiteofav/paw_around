import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/utils/date_utils.dart';
import 'package:paw_around/utils/utils.dart';

class PostDetailDetailsCard extends StatelessWidget {
  final LostFoundPost post;
  final bool isOwner;

  const PostDetailDetailsCard(
      {super.key, required this.post, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.details,
            style: AppTextStyles.interBoldStyle700(
                fontSize: 18, fontColor: AppColors.grey1100)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: smoothDecoration(
            cornerRadius: 20,
            color: AppColors.white,
            shadows: [
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: AppStrings.postedBy,
                value: isOwner
                    ? AppStrings.yourPost
                    : post.userName.orDefault(AppStrings.anonymous),
              ),
              const _RowDivider(),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label:
                    post.isLost ? AppStrings.lastSeenAt : AppStrings.foundAt,
                value: post.locationName,
              ),
              const _RowDivider(),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: AppStrings.contactPhone,
                value: post.contactPhone,
              ),
              const _RowDivider(),
              _InfoRow(
                icon: Icons.access_time,
                label: AppStrings.posted,
                value: AppDateUtils.getRelativeTime(post.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1, color: AppColors.border),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: smoothDecoration(
            cornerRadius: 8,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.interRegularStyle400(
                      fontSize: 12, fontColor: AppColors.grey600)),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTextStyles.interSemiBoldStyle600(
                      fontSize: 14, fontColor: AppColors.grey1000),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ],
          ),
        ),
      ],
    );
  }
}
