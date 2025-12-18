import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/vaccines/vaccine_master_data.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

class VaccineCard extends StatelessWidget {
  final VaccineMasterData masterData;
  final VaccineModel? existingVaccine;
  final VoidCallback onTap;

  const VaccineCard({
    super.key,
    required this.masterData,
    this.existingVaccine,
    required this.onTap,
  });

  bool get hasExistingVaccine => existingVaccine != null;

  String get statusText {
    if (!hasExistingVaccine) {
      return AppStrings.notAdded;
    }
    return '${AppStrings.lastGivenOn} ${_formatDate(existingVaccine!.dateGiven)}';
  }

  String get actionText {
    return hasExistingVaccine ? AppStrings.edit : AppStrings.addDate;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vaccine icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasExistingVaccine ? AppColors.primary.withValues(alpha: 0.1) : AppColors.iconBgLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.vaccines_outlined,
                    color: hasExistingVaccine ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Vaccine info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vaccine name
                      Text(
                        masterData.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Helper text
                      Text(
                        masterData.helperText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Status text
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: hasExistingVaccine ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: hasExistingVaccine ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: hasExistingVaccine ? AppColors.surface : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: hasExistingVaccine ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasExistingVaccine ? AppColors.textPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
