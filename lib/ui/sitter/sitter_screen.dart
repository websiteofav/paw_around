import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_location_action_card.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_search_location_field.dart';

/// Pet Sitters entry screen — shown before any address has been saved, so the
/// user is asked to set a location first. Once addresses exist, this makes
/// way for a "Saved Address" list below the action cards.
class SitterScreen extends StatelessWidget {
  const SitterScreen({super.key});

  void _onSearchTap(BuildContext context) {
    context.pushNamed(AppRoutes.pickLocation);
  }

  void _onUseCurrentLocation(BuildContext context) {
    // Still routes through the pin-confirm map — GPS fixes can drift a
    // building or two off, so the user gets a chance to nudge the pin.
    context.pushNamed(AppRoutes.pickLocation, extra: true);
  }

  void _onAddNewAddress(BuildContext context) {
    context.pushNamed(AppRoutes.pickLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.petSittersTitle,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 18,
            fontColor: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppEdgeInsets.horizontalLarge,
          child: Column(
            children: [
              AppSpacing.vertical32,
              Text(
                AppStrings.sitterLocationRequiredTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldStyle700(
                  fontSize: 24,
                  fontColor: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              AppSpacing.vertical24,
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5065, 1.0],
                  colors: [AppColors.white, Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AppIcons.otpCatIcon,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              AppSpacing.vertical24,
              SitterSearchLocationField(
                onTap: () => _onSearchTap(context),
              ),
              AppSpacing.vertical16,
              Row(
                children: [
                  Expanded(
                    child: SitterLocationActionCard(
                      icon: Image.asset(
                        AppIcons.gpsOutlineIcon,
                        color: AppColors.secondaryCTA,
                        colorBlendMode: BlendMode.srcIn,
                        height: 24,
                        width: 24,
                      ),
                      label: AppStrings.useCurrentLocation,
                      onTap: () => _onUseCurrentLocation(context),
                    ),
                  ),
                  AppSpacing.horizontal12,
                  Expanded(
                    child: SitterLocationActionCard(
                      icon: Image.asset(
                        AppIcons.addSquareIcon,
                        color: AppColors.secondaryCTA,
                        colorBlendMode: BlendMode.srcIn,
                        height: 24,
                        width: 24,
                      ),
                      label: AppStrings.addNewAddress,
                      onTap: () => _onAddNewAddress(context),
                    ),
                  ),
                ],
              ),
              AppSpacing.vertical24,
            ],
          ),
        ),
      ),
    );
  }
}
