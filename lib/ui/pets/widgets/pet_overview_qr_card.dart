import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewQrCard extends StatelessWidget {
  final PetModel pet;

  const PetOverviewQrCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: () {
        context.pushNamed(AppRoutes.petQr, extra: pet);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: smoothDecoration(
          cornerRadius: 24,
          color: AppColors.white,
          side: const BorderSide(color: AppColors.border),
          shadows: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: smoothDecoration(
                cornerRadius: 12,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.viewPetQr,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 14,
                  fontColor: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
