import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Shows a notification permission dialog with contextual messaging
/// Returns true if user wants to enable reminders, false otherwise
Future<bool> showNotificationPermissionDialog({
  required BuildContext context,
  required String petName,
  required ReminderType reminderType,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pet-themed icon with paw and notification bell
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Never Miss $petName's Care",
            style: AppTextStyles.semiBoldStyle600(fontSize: 20, fontColor: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Enable notifications to get timely reminders for $petName's ${reminderType.displayName}.",
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Benefits list
          Container(
            padding: const EdgeInsets.all(12),
            decoration: smoothDecoration(
              cornerRadius: 12,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
            child: Column(
              children: [
                _buildBenefitRow(Icons.check_circle_outline, 'Timely reminders before due dates'),
                const SizedBox(height: 8),
                _buildBenefitRow(Icons.check_circle_outline, 'Keep $petName healthy & happy'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: AppStrings.notNow,
                  textSize: 14,
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  text: AppStrings.enable,
                  textSize: 14,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  return result ?? false;
}

Widget _buildBenefitRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.regularStyle400(
            fontSize: 13,
            fontColor: AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}
