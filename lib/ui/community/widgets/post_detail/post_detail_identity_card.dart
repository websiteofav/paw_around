import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

/// Floating name/breed card that overlaps the hero photo's bottom edge,
/// with a share button in place of the old app-bar share icon.
class PostDetailIdentityCard extends StatelessWidget {
  final LostFoundPost post;
  final VoidCallback onShare;

  const PostDetailIdentityCard(
      {super.key, required this.post, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        [post.breed, post.color].where((s) => s.isNotEmpty).join(' · ');
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: smoothDecoration(
        cornerRadius: 24,
        color: AppColors.white,
        shadows: [
          BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.petName,
                    style: AppTextStyles.interBoldStyle700(
                        fontSize: 24, fontColor: AppColors.grey1100)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTextStyles.interRegularStyle400(
                          fontSize: 14, fontColor: AppColors.grey600)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onShare,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: smoothDecoration(
                cornerRadius: 14,
                color: AppColors.background3,
              ),
              child: Image.asset(
                AppIcons.shareIcon,
                width: 20,
                height: 20,
                color: AppColors.secondaryCTA,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
