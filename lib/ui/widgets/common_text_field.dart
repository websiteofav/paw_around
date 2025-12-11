import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? forgotPasswordText;
  final VoidCallback? onForgotPasswordPressed;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.isPassword = false,
    this.forgotPasswordText,
    this.onForgotPasswordPressed,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.patternColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? !isPasswordVisible : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: isPassword ? _buildPasswordSuffix() : null,
        ),
      ),
    );
  }

  Widget? _buildPasswordSuffix() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (forgotPasswordText != null && onForgotPasswordPressed != null)
          TextButton(
            onPressed: onForgotPasswordPressed,
            child: Text(
              forgotPasswordText!,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
              ),
            ),
          ),
        IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
