import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class UrgentVaccineCard extends StatelessWidget {
  final String vaccineName;
  final int daysUntilDue;
  final VoidCallback onFindVetsPressed;
  final int? nearbyVetsCount;
  final double? distanceKm;

  const UrgentVaccineCard({
    super.key,
    required this.vaccineName,
    required this.daysUntilDue,
    required this.onFindVetsPressed,
    this.nearbyVetsCount,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.urgentGradientStart,
            AppColors.urgentGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.urgentGradientStart.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Frosted glass icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.vaccines_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              // Due badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.urgentBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getDueBadgeText(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.urgentBadgeText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Vaccine name
          Text(
            vaccineName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            '${AppStrings.importantForHealth} 💉',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 16),

          // CTA Button with scale effect
          ScaleButton(
            onPressed: onFindVetsPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                AppStrings.findNearbyVets,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.urgentGradientStart,
                ),
              ),
            ),
          ),

          // Helper text with location
          if (nearbyVetsCount != null && distanceKm != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '$nearbyVetsCount vets within ${distanceKm!.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getDueBadgeText() {
    if (daysUntilDue < 0) {
      return 'Overdue by ${-daysUntilDue} days';
    } else if (daysUntilDue == 0) {
      return 'Due today';
    } else if (daysUntilDue == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysUntilDue days';
    }
  }
}
