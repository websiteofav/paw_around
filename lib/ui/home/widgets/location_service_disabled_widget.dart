import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Widget displayed when location services are disabled
class LocationServiceDisabledWidget extends StatelessWidget {
  final LocationService locationService;
  final VoidCallback onRetry;

  const LocationServiceDisabledWidget({
    super.key,
    required this.locationService,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_disabled_rounded,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.locationServicesDisabled,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 20,
                fontColor: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.locationServicesDisabledMessage,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CommonButton(
              text: AppStrings.openLocationSettings,
              onPressed: () async {
                await locationService.openLocationSettings();
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            CommonButton(
              text: AppStrings.retry,
              onPressed: onRetry,
              variant: ButtonVariant.outline,
              size: ButtonSize.medium,
              icon: Icons.refresh,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
