import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/utils/url_utils.dart';

class PostDetailBottomBar extends StatelessWidget {
  final LostFoundPost post;

  const PostDetailBottomBar({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                text: AppStrings.callOwner,
                onPressed: () => UrlUtils.openPhone(post.contactPhone),
                variant: ButtonVariant.outline,
                icon: Icons.phone,
                size: ButtonSize.small,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommonButton(
                text: AppStrings.getDirections,
                onPressed: () => UrlUtils.openDirections(
                    latitude: post.latitude, longitude: post.longitude),
                variant: ButtonVariant.primary,
                icon: Icons.directions,
                size: ButtonSize.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
