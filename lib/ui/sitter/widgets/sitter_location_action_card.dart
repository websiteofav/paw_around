import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// "Use current location" / "Add new Address" card shown on the sitter
/// location prompt.
class SitterLocationActionCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const SitterLocationActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        padding: AppEdgeInsets.allMedium,
        decoration: smoothDecoration(
          cornerRadius: 24,
          color: AppColors.white,
          side: const BorderSide(color: AppColors.grey100),
          shadows: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0510),
              offset: const Offset(0, 3),
              blurRadius: 7,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0392),
              offset: const Offset(0, 13),
              blurRadius: 13,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0314),
              offset: const Offset(0, 30),
              blurRadius: 18,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0118),
              offset: const Offset(0, 54),
              blurRadius: 21,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0),
              offset: const Offset(0, 84),
              blurRadius: 23,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            AppSpacing.vertical10,
            Text(
              label,
              style: AppTextStyles.interBoldStyle700(
                fontSize: 16,
                fontColor: AppColors.secondaryCTA,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
