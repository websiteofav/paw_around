import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

class VaccineSnoozeBanner extends StatelessWidget {
  final VaccineModel vaccine;
  final bool isUnsnoozeing;
  final VoidCallback onUnsnooze;

  const VaccineSnoozeBanner({
    super.key,
    required this.vaccine,
    required this.isUnsnoozeing,
    required this.onUnsnooze,
  });

  @override
  Widget build(BuildContext context) {
    final snoozedUntil = vaccine.snoozedUntil;
    final daysLeft = snoozedUntil != null
        ? snoozedUntil.difference(DateTime.now()).inDays
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: smoothDecoration(
        cornerRadius: 12,
        color: AppColors.warning.withValues(alpha: 0.1),
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.snooze, color: AppColors.warning, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.reminderSnoozed,
                  style: AppTextStyles.semiBoldStyle600(
                      fontColor: AppColors.textPrimary)),
              Text(
                '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} remaining',
                style: AppTextStyles.regularStyle400(
                    fontSize: 12, fontColor: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: isUnsnoozeing ? null : onUnsnooze,
          child: isUnsnoozeing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppStrings.unsnooze,
                  style: AppTextStyles.semiBoldStyle600(
                      fontColor: AppColors.warning)),
        ),
      ]),
    );
  }
}
