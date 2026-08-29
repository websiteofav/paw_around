import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// Read-only, tappable "search for your location" pill. Tapping it hands off
/// to a dedicated location search screen rather than searching inline.
class SitterSearchLocationField extends StatelessWidget {
  final VoidCallback onTap;

  const SitterSearchLocationField({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: smoothDecoration(
          cornerRadius: 12,
          color: AppColors.white,
          side: const BorderSide(color: AppColors.neutral300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.sitterSearchLocationHint,
                style: AppTextStyles.interMediumStyle500(
                  fontSize: 18,
                  fontColor: AppColors.neutral300,
                ),
              ),
            ),
            Image.asset(
              AppIcons.gpsIcon,
              color: AppColors.secondaryCTA,
              colorBlendMode: BlendMode.srcIn,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
