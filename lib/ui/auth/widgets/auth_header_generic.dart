import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/intro/widgets/app_logo.dart';

enum AuthHeaderType { login, signup }

class AuthHeaderGeneric extends StatelessWidget {
  final AuthHeaderType headerType;

  const AuthHeaderGeneric({
    super.key,
    required this.headerType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        const AppLogo(),

        const SizedBox(height: 24),

        // App Name
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 16),

        // Title based on auth type
        Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle based on auth type
        Text(
          _getSubtitle(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (headerType) {
      case AuthHeaderType.login:
        return AppStrings.welcomeBack;
      case AuthHeaderType.signup:
        return AppStrings.createAccount;
    }
  }

  String _getSubtitle() {
    switch (headerType) {
      case AuthHeaderType.login:
        return AppStrings.loginInstruction;
      case AuthHeaderType.signup:
        return AppStrings.signupSubtitle;
    }
  }
}
