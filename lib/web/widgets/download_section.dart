import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppEdgeInsets.horizontalLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.landingDownloadHeading,
            style: AppTextStyles.extraBoldStyle800(
              fontSize: 28,
              fontColor: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical24,
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              final buttons = [
                CommonButton(
                  text: AppStrings.landingDownloadOnAndroid,
                  onPressed: () {},
                  isFullWidth: isMobile,
                  size: ButtonSize.large,
                  icon: Icons.android,
                  customColor: AppColors.authPrimaryButton,
                ),
                if (!isMobile) AppSpacing.horizontal16,
                CommonButton(
                  text: AppStrings.landingIosComingSoon,
                  onPressed: () {},
                  isFullWidth: isMobile,
                  size: ButtonSize.large,
                  variant: ButtonVariant.secondary,
                  customColor: AppColors.surface,
                  customTextColor: AppColors.textSecondary,
                  icon: Icons.apple,
                ),
              ];

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buttons[0],
                    AppSpacing.vertical16,
                    buttons.last,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons,
              );
            },
          ),
        ],
      ),
    );
  }
}
