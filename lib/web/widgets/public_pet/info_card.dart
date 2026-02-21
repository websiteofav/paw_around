import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Generic white card with title and icon+label rows for Basic Info.
class PublicPetInfoCard extends StatelessWidget {
  final String title;
  final List<PublicPetInfoRow> rows;

  const PublicPetInfoCard({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 18,
              fontColor: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vertical16,
          for (var i = 0; i < rows.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  rows[i].icon,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rows[i].value,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 14,
                      fontColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (i != rows.length - 1) AppSpacing.vertical12,
          ],
        ],
      ),
    );
  }
}

class PublicPetInfoRow {
  final IconData icon;
  final String value;

  const PublicPetInfoRow({required this.icon, required this.value});
}
