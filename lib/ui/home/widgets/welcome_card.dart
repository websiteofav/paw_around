import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     AppColors.primary.withValues(alpha: 0.1),
        //     AppColors.secondary.withValues(alpha: 0.02),
        //   ],
        // ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        color: AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie Animation with fallback
          LottieBuilder.asset(
            AppIcons.addPetAnimation,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if Lottie fails
              return Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  size: 80,
                  color: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            AppStrings.welcomeToPawAroundHome,
            style: AppTextStyles.boldStyle700(
              fontSize: 22,
              fontColor: AppColors.textPrimary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            AppStrings.addPetToGetStarted,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Benefits List
          _buildBenefit(Icons.check_circle, AppStrings.neverMissVaccines),
          const SizedBox(height: 10),
          _buildBenefit(Icons.check_circle, AppStrings.findVetsNearby),
          const SizedBox(height: 10),
          _buildBenefit(Icons.check_circle, AppStrings.trackHealthWellness),

          const SizedBox(height: 28),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed(AppRoutes.addPet);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Text(
                AppStrings.addYourFirstPet,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 16,
                  fontColor: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.mediumStyle500(fontSize: 13, fontColor: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
