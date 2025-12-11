import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class GetStartedButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GetStartedButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      text: AppStrings.getStartedButton,
      onPressed: onPressed ?? () => _showWelcomeMessage(context),
      variant: ButtonVariant.primary,
      size: ButtonSize.medium,
      isFullWidth: true,
    );
  }

  void _showWelcomeMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          AppStrings.welcomeMessage,
          style: AppTextStyles.welcomeMessage,
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
