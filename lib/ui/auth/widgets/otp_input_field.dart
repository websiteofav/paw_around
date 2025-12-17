import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:paw_around/constants/app_colors.dart';

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
      controller: controller,
      onChanged: onChanged,
      onCompleted: onCompleted,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(14),
        fieldHeight: 56,
        fieldWidth: 48,
        activeFillColor: AppColors.surface,
        inactiveFillColor: AppColors.surface,
        selectedFillColor: AppColors.surface,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.border,
        selectedColor: AppColors.primary,
        borderWidth: 1.5,
      ),
      cursorColor: AppColors.primary,
      animationDuration: const Duration(milliseconds: 200),
      enableActiveFill: true,
      keyboardType: TextInputType.number,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
