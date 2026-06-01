import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: smoothDecoration(
            cornerRadius: 16,
            color: AppColors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                message,
                style: AppTextStyles.mediumStyle500(
                  fontSize: 16,
                  fontColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

