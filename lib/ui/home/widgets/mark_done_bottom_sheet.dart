import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class MarkDoneBottomSheet extends StatelessWidget {
  final String actionTitle;
  final VoidCallback onConfirm;

  const MarkDoneBottomSheet({
    super.key,
    required this.actionTitle,
    required this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, String actionTitle) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkDoneBottomSheet(
        actionTitle: actionTitle,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            AppStrings.confirmMarkDone,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            AppStrings.markDoneDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: AppStrings.cancel,
                  variant: ButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CommonButton(
                  text: AppStrings.confirm,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
