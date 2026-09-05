import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Headline + faded cat illustration shown before any address has been
/// saved (or while the saved-address list is still loading).
class SitterEmptyState extends StatelessWidget {
  const SitterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}
