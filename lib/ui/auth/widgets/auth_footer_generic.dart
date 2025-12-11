import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_routes.dart';

enum AuthFooterType { login, signup }

class AuthFooterGeneric extends StatelessWidget {
  final AuthFooterType footerType;

  const AuthFooterGeneric({
    super.key,
    required this.footerType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _getPromptText(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => _handleNavigation(context),
          child: Text(
            _getActionText(),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getPromptText() {
    switch (footerType) {
      case AuthFooterType.login:
        return AppStrings.noAccount;
      case AuthFooterType.signup:
        return AppStrings.alreadyHaveAccount;
    }
  }

  String _getActionText() {
    switch (footerType) {
      case AuthFooterType.login:
        return AppStrings.signUp;
      case AuthFooterType.signup:
        return AppStrings.logIn;
    }
  }

  void _handleNavigation(BuildContext context) {
    switch (footerType) {
      case AuthFooterType.login:
        context.pushNamed(AppRoutes.signup);
        break;
      case AuthFooterType.signup:
        context.pushNamed(AppRoutes.login);
        break;
    }
  }
}
