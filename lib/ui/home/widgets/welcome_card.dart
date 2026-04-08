import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                AppIcons.homeCatDogAffectionIcon,
                height: 280,
                fit: BoxFit.contain,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.white.withValues(alpha: 0.15),
                        AppColors.white,
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.letsMeetYourPet,
            style: AppTextStyles.boldStyle700(
              fontSize: 24,
              fontColor: AppColors.grey1000,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.trackHealthGroomingCare,
            style: AppTextStyles.interMediumStyle500(
              fontSize: 16,
              fontColor: AppColors.grey700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pushNamed(AppRoutes.addPet),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.grey1000,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.add,
                      size: 18, color: AppColors.grey1000),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.addYourFirstPet,
                  style: AppTextStyles.interBoldStyle700(
                    fontSize: 16,
                    fontColor: AppColors.grey1000,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
