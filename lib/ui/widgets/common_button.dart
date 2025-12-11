import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/constants/app_constants.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? customColor;
  final Color? customTextColor;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.customColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.primary,
          foregroundColor: customTextColor ?? AppColors.background,
          elevation: 8,
          shadowColor: (customColor ?? AppColors.primary).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.secondary,
          foregroundColor: customTextColor ?? AppColors.background,
          elevation: 4,
          shadowColor: (customColor ?? AppColors.secondary).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
        );
      case ButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: customTextColor ?? AppColors.primary,
          elevation: 0,
          side: BorderSide(
            color: customColor ?? AppColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
        );
      case ButtonVariant.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: customTextColor ?? AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
        );
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? Colors.red,
          foregroundColor: customTextColor ?? Colors.white,
          elevation: 4,
          shadowColor: (customColor ?? Colors.red).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
        );
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = AppTextStyles.buttonText.copyWith(
      color: _getTextColor(),
    );

    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 14);
      case ButtonSize.medium:
        return baseStyle.copyWith(fontSize: 16);
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 18);
    }
  }

  Color _getTextColor() {
    if (customTextColor != null) return customTextColor!;

    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return AppColors.background;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return AppColors.primary;
    }
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return AppConstants.buttonHeight;
      case ButtonSize.large:
        return 64;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 20;
      case ButtonSize.medium:
        return AppConstants.buttonBorderRadius;
      case ButtonSize.large:
        return 32;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}
