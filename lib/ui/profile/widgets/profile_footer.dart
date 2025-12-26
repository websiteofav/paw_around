import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class ProfileFooter extends StatelessWidget {
  final String appVersion;

  const ProfileFooter({
    super.key,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.appName,
              style: AppTextStyles.regularStyle400(
                fontSize: 13,
                fontColor: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          appVersion,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
