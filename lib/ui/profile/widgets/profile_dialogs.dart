import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Shows logout confirmation dialog
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
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
              Icons.logout,
              size: 32,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.logOutConfirmTitle,
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 20, fontColor: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.logOutConfirmMessage,
            style: AppTextStyles.regularStyle400(
                fontSize: 14, fontColor: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    AppStrings.cancel,
                    style: AppTextStyles.mediumStyle500(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<AuthBloc>().add(SignOut());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    AppStrings.logout,
                    style: AppTextStyles.semiBoldStyle600(
                        fontSize: 15, fontColor: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Shows delete account confirmation dialog
void showDeleteAccountDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
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
              Icons.warning_amber_rounded,
              size: 32,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.deleteAccountTitle,
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 20, fontColor: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.deleteAccountWarning,
            style: AppTextStyles.regularStyle400(
                fontSize: 14, fontColor: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildBullet(AppStrings.deleteAccountBullet1),
          _buildBullet(AppStrings.deleteAccountBullet2),
          _buildBullet(AppStrings.deleteAccountBullet3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: smoothDecoration(
              cornerRadius: 8,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.deleteAccountFinal,
                    style: AppTextStyles.mediumStyle500(
                        fontSize: 12, fontColor: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    AppStrings.cancel,
                    style: AppTextStyles.mediumStyle500(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    AppStrings.delete,
                    style: AppTextStyles.semiBoldStyle600(
                        fontSize: 15, fontColor: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Shows delete moment confirmation dialog (app-compliant)
void showDeleteMomentDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.xl,
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
          AppSpacing.vertical16,
          Text(
            AppStrings.deleteMoment,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 20,
              fontColor: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.deleteMomentConfirmation,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  text: AppStrings.delete,
                  variant: ButtonVariant.danger,
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Shows re-authentication dialog
void showReAuthDialog(
  BuildContext context, {
  required bool hasGoogle,
  required bool hasPhone,
  required VoidCallback onGoogleTap,
  required VoidCallback onPhoneTap,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Confirm Identity',
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 20, fontColor: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.reAuthRequired,
            style: AppTextStyles.regularStyle400(
                fontSize: 14, fontColor: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (hasGoogle)
            CommonButton(
              text: 'Sign in with Google',
              icon: Icons.g_mobiledata,
              variant: ButtonVariant.outline,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onGoogleTap();
              },
            ),
          if (hasPhone) ...[
            const SizedBox(height: 12),
            CommonButton(
              text: 'Sign in with Phone',
              icon: Icons.phone,
              variant: ButtonVariant.outline,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onPhoneTap();
              },
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.regularStyle400(
                  fontColor: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBullet(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.regularStyle400(
                fontSize: 13, fontColor: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}
