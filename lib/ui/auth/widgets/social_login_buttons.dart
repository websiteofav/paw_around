import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Button
        _buildSocialButton(
          context: context,
          icon: AppIcons.googleIcon,
          text: AppStrings.continueWithGoogle,
          onPressed: () {
            context.read<AuthBloc>().add(LoginWithGoogle());
          },
        ),

        const SizedBox(height: 12),

        // Apple Button
        _buildSocialButton(
          context: context,
          icon: AppIcons.appleIcon,
          text: AppStrings.continueWithApple,
          onPressed: () {
            context.read<AuthBloc>().add(LoginWithApple());
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.patternColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
