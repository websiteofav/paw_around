import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class SetupReminderCard extends StatelessWidget {
  final String petName;
  final VoidCallback onAddVaccinePressed;

  const SetupReminderCard({
    super.key,
    required this.petName,
    required this.onAddVaccinePressed,
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
          // Icon and text row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon in circular background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.iconBgLight,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.completeHealthDetails.replaceAll('%s', petName),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add vaccines and health records',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAddVaccinePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                AppStrings.addVaccineDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
