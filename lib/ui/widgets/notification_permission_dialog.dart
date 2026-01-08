import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
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
              Icons.notifications_active_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Never Miss $petName's Care",
            style: AppTextStyles.semiBoldStyle600(fontSize: 20, fontColor: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Get reminders so you never forget $petName's ${reminderType.displayName}.",
            style: AppTextStyles.regularStyle400(fontSize: 14, fontColor: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: AppStrings.notNow,
                  textSize: 14,
                  variant: ButtonVariant.outline,
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
