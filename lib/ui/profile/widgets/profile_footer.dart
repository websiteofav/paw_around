import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
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
            SvgPicture.asset(
              AppIcons.pawProfileIcon,
              height: 28,
              width: 34,
              colorFilter:
                  const ColorFilter.mode(AppColors.grey150, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.appName,
              style: AppTextStyles.regularStyle400(
                fontSize: 24,
                fontColor: AppColors.grey150,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          appVersion,
          style: AppTextStyles.interMediumStyle500(
            fontSize: 16,
            fontColor: AppColors.grey150,
          ),
        ),
      ],
    );
  }
}
