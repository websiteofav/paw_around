import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.logoSize,
      height: AppConstants.logoSize,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppConstants.logoSize / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Location pin background
          const Icon(
            Icons.location_on,
            size: AppConstants.logoIconSize,
            color: AppColors.background,
          ),
          // Paw print overlay
          Positioned(
            top: 20,
            child: Container(
              width: AppConstants.pawContainerSize,
              height: AppConstants.pawContainerSize,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppConstants.pawContainerSize / 2),
              ),
              child: const Icon(
                Icons.pets,
                size: AppConstants.pawIconSize,
                color: AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
