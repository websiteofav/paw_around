import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PetQrScreen extends StatelessWidget {
  final PetModel pet;

  const PetQrScreen({
    super.key,
    required this.pet,
  });

  static const String _qrBaseUrl = 'https://pawaround.in/p/';

  @override
  Widget build(BuildContext context) {
    final String? qrData =
        pet.petPublicId != null ? '$_qrBaseUrl${pet.petPublicId}' : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.viewPetQr,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 20,
            fontColor: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppEdgeInsets.allLarge,
          child: Column(
            children: [
              Text(
                pet.name,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 22,
                  fontColor: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (qrData != null) _buildQrCard(context, qrData),
              if (qrData == null) _buildUnavailableMessage(context),
              const SizedBox(height: 24),
              Text(
                AppStrings.scanMeToHelpGetHome,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, String qrData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: qrData,
        size: 220,
        backgroundColor: AppColors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.textPrimary,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildUnavailableMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        AppStrings.qrNotAvailableForPet,
        style: AppTextStyles.regularStyle400(
          fontSize: 14,
          fontColor: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
