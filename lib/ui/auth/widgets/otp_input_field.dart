import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';

class OTPInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;
  final Function(String) onChanged;

  const OTPInputField({
    super.key,
    required this.controller,
    required this.onCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      autoFocus: true,
      controller: controller,
      onChanged: onChanged,
      onCompleted: onCompleted,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 56,
        fieldWidth: 44,
        activeFillColor: AppColors.surface,
        inactiveFillColor: AppColors.surface,
        selectedFillColor: AppColors.surface,
        activeColor: AppColors.secondaryCTA,
        inactiveColor: AppColors.border.withValues(alpha: 0.6),
        selectedColor: AppColors.secondaryCTA,
        borderWidth: 1.0,
      ),
      hintCharacter: '—',
      hintStyle: AppTextStyles.semiBoldStyle600(
          fontSize: 14, fontColor: AppColors.neutral200),
      cursorColor: AppColors.primary,
      animationDuration: const Duration(milliseconds: 200),
      enableActiveFill: true,
      keyboardType: TextInputType.number,
      textStyle: AppTextStyles.semiBoldStyle600(
          fontSize: 20, fontColor: AppColors.textPrimary),
    );
  }
}
