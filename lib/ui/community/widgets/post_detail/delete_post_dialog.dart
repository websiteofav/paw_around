import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class DeletePostDialog {
  DeletePostDialog._();

  static void show({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.deletePost,
                style: AppTextStyles.interSemiBoldStyle600(
                  fontSize: 18,
                  fontColor: AppColors.grey1100,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.deletePostConfirmation,
                style: AppTextStyles.interRegularStyle400(
                    fontSize: 14, fontColor: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.cancel,
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.small,
                      onPressed: isDeleting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.delete,
                      variant: ButtonVariant.danger,
                      size: ButtonSize.small,
                      isLoading: isDeleting,
                      onPressed: isDeleting
                          ? null
                          : () {
                              setDialogState(() => isDeleting = true);
                              onConfirm();
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
