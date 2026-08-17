import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Mint info/tip banner: icon + text on [AppColors.background3].
class InfoBanner extends StatelessWidget {
  final String text;

  const InfoBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusMD,
        color: AppColors.background3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppIcons.informationIcon,
            width: 20,
            height: 20,
            color: AppColors.navColor,
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.interMediumStyle500(
                  fontSize: 14, fontColor: AppColors.navColor),
            ),
          ),
        ],
      ),
    );
  }
}
