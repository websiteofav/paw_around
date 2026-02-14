import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/utils/url_utils.dart';

/// Footer for public pet profile: copyright + Privacy Policy link.
class PublicPetFooter extends StatelessWidget {
  const PublicPetFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.copyrightPawAround2026,
          style: AppTextStyles.regularStyle400(
            fontSize: 12,
            fontColor: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => UrlUtils.launch(AppStrings.privacyPolicyUrl),
          child: Text(
            AppStrings.privacyPolicyLink,
            style: AppTextStyles.regularStyle400(
              fontSize: 12,
              fontColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
