import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';

enum SocialAuthType { google, email }

class SocialAuthButton extends StatelessWidget {
  final SocialAuthType type;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Text(
              _getLabel(),
              style: AppTextStyles.mediumStyle500(fontSize: 16, fontColor: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case SocialAuthType.google:
        return Image.asset(
          'assets/auth/google_icon.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.g_mobiledata, size: 24, color: Colors.red);
          },
        );
      case SocialAuthType.email:
        return Icon(Icons.mail_outline, size: 24, color: AppColors.textPrimary);
    }
  }

  String _getLabel() {
    switch (type) {
      case SocialAuthType.google:
        return 'Continue with Google';
      case SocialAuthType.email:
        return 'Continue with Email';
    }
  }
}
