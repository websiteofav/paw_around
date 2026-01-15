import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/services/animation_service.dart';

class WelcomeCard extends StatefulWidget {
  const WelcomeCard({super.key});

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard> {
  String? _lottiePath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimation();
  }

  Future<void> _loadAnimation() async {
    final path =
        await AnimationService.getLottieFile(AppIcons.addPetAnimationFileName);
    if (mounted) {
      setState(() {
        _lottiePath = path;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        color: AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie Animation from Firebase Storage with fallback
          SizedBox(
            height: 144,
            child: _loading
                ? _buildLoadingState()
                : _lottiePath != null
                    ? _buildLottieAnimation()
                    : _buildIconFallback(),
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

  Widget _buildLottieAnimation() {
    // Check if it's a network URL or local file path
    if (_lottiePath!.startsWith('http')) {
      return Lottie.network(
        _lottiePath!,
        height: 144,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildIconFallback();
        },
      );
    } else {
      // Local cached file
      return Lottie.file(
        File(_lottiePath!),
        height: 144,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildIconFallback();
        },
      );
    }
  }

  Widget _buildLoadingState() {
    return Container(
      height: 144,
      width: 144,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildIconFallback() {
    return Container(
      height: 144,
      width: 144,
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
  }
}
