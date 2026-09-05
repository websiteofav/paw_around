import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/upcoming_session_model.dart';

/// Pill row showing which pet the session is for.
class UpcomingSessionPetRow extends StatelessWidget {
  final UpcomingSessionModel session;

  const UpcomingSessionPetRow({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.cardPaddingSmall,
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusFull,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          AppSpacing.horizontal12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.sessionForPrefix} ${session.petName}',
                  style: AppTextStyles.interBoldStyle700(
                      fontSize: 16, fontColor: AppColors.grey1000),
                ),
                Text(
                  '${session.petBreed} · ${session.petAgeLabel}',
                  style: AppTextStyles.interRegularStyle400(
                      fontSize: 12, fontColor: AppColors.grey600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imagePath = session.petImagePath;
    if (imagePath == null || imagePath.isEmpty || !imagePath.startsWith('http')) {
      return const CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.iconBgLight,
        child: Icon(Icons.pets, color: AppColors.primaryDark),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.iconBgLight,
      foregroundImage: CachedNetworkImageProvider(imagePath),
    );
  }
}
