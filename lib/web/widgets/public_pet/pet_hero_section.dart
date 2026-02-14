import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Hero: pet image, name, breed • age, status badge, Call / Message / Share Location.
class PublicPetHeroSection extends StatelessWidget {
  final PetModel pet;
  final bool isWideLayout;

  const PublicPetHeroSection({
    super.key,
    required this.pet,
    this.isWideLayout = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isWideLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(context),
          AppSpacing.horizontal24,
          Expanded(child: _buildDetails(context)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(context),
        AppSpacing.vertical24,
        _buildDetails(context),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    const size = 280.0;
    return Container(
      width: isWideLayout ? size : null,
      height: size,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.lg,
        child: pet.imagePath != null && pet.imagePath!.startsWith('http')
            ? Image.network(
                pet.imagePath!,
                fit: BoxFit.cover,
                width: isWideLayout ? size : null,
                height: size,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.border,
      child: Icon(
        Icons.pets,
        size: 80,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pet.name,
          style: AppTextStyles.boldStyle700(
            fontSize: 28,
            fontColor: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vertical8,
        Text(
          '${pet.breed} • ${pet.ageString}',
          style: AppTextStyles.regularStyle400(
            fontSize: 16,
            fontColor: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vertical16,
        _StatusBadge(isLost: pet.isLost),
        AppSpacing.vertical24,
        _ActionButtons(isWideLayout: isWideLayout),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLost;

  const _StatusBadge({required this.isLost});

  @override
  Widget build(BuildContext context) {
    final text = isLost
        ? AppStrings.publicPetStatusMissing
        : AppStrings.publicPetStatusSafeAtHome;
    final color = isLost ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space8,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorderRadius.sm,
      ),
      child: Text(
        text,
        style: AppTextStyles.semiBoldStyle600(
          fontSize: 14,
          fontColor: AppColors.white,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isWideLayout;

  const _ActionButtons({required this.isWideLayout});

  @override
  Widget build(BuildContext context) {
    if (isWideLayout) {
      return Row(
        children: [
          Expanded(
            child: CommonButton(
              text: AppStrings.callOwner,
              icon: Icons.phone,
              onPressed: () {},
              variant: ButtonVariant.primary,
              customColor: AppColors.cardBlueIcon,
              size: ButtonSize.large,
              isFullWidth: true,
            ),
          ),
          AppSpacing.horizontal12,
          Expanded(
            child: CommonButton(
              text: AppStrings.messageOwner,
              icon: Icons.message_outlined,
              onPressed: () {},
              variant: ButtonVariant.outline,
              size: ButtonSize.large,
              isFullWidth: true,
            ),
          ),
          AppSpacing.horizontal12,
          Expanded(
            child: CommonButton(
              text: AppStrings.shareLocation,
              icon: Icons.location_on_outlined,
              onPressed: () {},
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              isFullWidth: true,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        CommonButton(
          text: AppStrings.callOwner,
          icon: Icons.phone,
          onPressed: () {},
          variant: ButtonVariant.primary,
          customColor: AppColors.cardBlueIcon,
          size: ButtonSize.large,
          isFullWidth: true,
        ),
        AppSpacing.vertical12,
        CommonButton(
          text: AppStrings.messageOwner,
          icon: Icons.message_outlined,
          onPressed: () {},
          variant: ButtonVariant.outline,
          size: ButtonSize.large,
          isFullWidth: true,
        ),
        AppSpacing.vertical12,
        CommonButton(
          text: AppStrings.shareLocation,
          icon: Icons.location_on_outlined,
          onPressed: () {},
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          isFullWidth: true,
        ),
      ],
    );
  }
}
