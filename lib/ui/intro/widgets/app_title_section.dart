import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/animated_content.dart';

class AppTitleSection extends StatelessWidget {
  final Animation<double> animation;

  const AppTitleSection({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContent(
          animation: animation,
          child: Text(
            AppStrings.introTitle,
            style: AppTextStyles.boldStyle700(fontSize: 32, fontColor: AppColors.primary, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContent(
          animation: animation,
          child: Text(
            AppStrings.introDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.regularStyle400(fontSize: 14, fontColor: AppColors.textSecondary, letterSpacing: 0.3),
          ),
        ),
      ],
    );
  }
}
