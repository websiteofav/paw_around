import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

/// "Is this your pet?" radio card, plus the lost/found heading + subtitle
/// that changes based on the selected [PostType].
class PetTypeSelector extends StatelessWidget {
  final PostType postType;
  final ValueChanged<PostType> onChanged;

  const PetTypeSelector({
    super.key,
    required this.postType,
    required this.onChanged,
  });

  bool get _isLost => postType == PostType.lost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: smoothDecoration(
            cornerRadius: 36,
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
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0),
                  blurRadius: 23,
                  offset: const Offset(0, 84)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.isThisYourPet,
                      style: AppTextStyles.boldStyle700(
                          fontSize: 18, fontColor: AppColors.grey1100),
                    ),
                    const SizedBox(height: 8),
                    _buildOption(PostType.lost, AppStrings.yesILostMyPet),
                    _buildOption(PostType.found, AppStrings.noIFoundAPet),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.65, 1.0],
                  colors: [Colors.white, Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AppIcons.petDetectiveIllustration,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AppIcons.reportPetIcon, width: 64, height: 64),
            const SizedBox(height: 8),
            Text(
              _isLost ? AppStrings.reportALostPet : AppStrings.reportAFoundPet,
              style: AppTextStyles.boldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100),
            ),
            const SizedBox(height: 8),
            Text(
              _isLost
                  ? AppStrings.actQuicklyPetsAreOftenFound
                  : AppStrings.helpReuniteThisPetWithTheirFamily,
              style: AppTextStyles.interMediumStyle500(
                  fontSize: 16, fontColor: AppColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(PostType type, String label) {
    final isSelected = postType == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.secondaryCTA : AppColors.grey600,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 16, fontColor: AppColors.grey1000),
            ),
          ],
        ),
      ),
    );
  }
}
