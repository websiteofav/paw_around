import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class PostDetailOwnerActions extends StatelessWidget {
  final bool isResolved;
  final VoidCallback onMarkResolved;
  final VoidCallback onReopen;
  final VoidCallback onDelete;

  const PostDetailOwnerActions({
    super.key,
    required this.isResolved,
    required this.onMarkResolved,
    required this.onReopen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isResolved)
          CommonButton(
            text: AppStrings.markAsResolved,
            onPressed: onMarkResolved,
            variant: ButtonVariant.outline,
            icon: Icons.check_circle,
            customColor: AppColors.secondaryCTA,
            customTextColor: AppColors.secondaryCTA,
          )
        else
          CommonButton(
            text: AppStrings.reopenPost,
            onPressed: onReopen,
            variant: ButtonVariant.outline,
            icon: Icons.refresh,
            customColor: AppColors.warning,
            customTextColor: AppColors.warning,
          ),
        const SizedBox(height: 12),
        CommonButton(
          text: AppStrings.deletePost,
          onPressed: onDelete,
          variant: ButtonVariant.danger,
          icon: Icons.delete_outline,
        ),
      ],
    );
  }
}
