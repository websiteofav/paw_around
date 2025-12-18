import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class ActionCtaCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final String helperText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onLearnMoreTap;

  const ActionCtaCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.helperText,
    required this.onButtonPressed,
    this.onLearnMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (onLearnMoreTap != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onLearnMoreTap,
              child: const Text(
                AppStrings.learnMore,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          CommonButton(
            text: buttonText,
            onPressed: onButtonPressed,
            size: ButtonSize.medium,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              helperText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
