import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';

class CommonFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool enabled;
  final int? maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final Color? asteriskColor;
  final Widget? trailing;

  const CommonFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.isRequired = false,
    this.asteriskColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 14, fontColor: AppColors.grey1000),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTextStyles.interRegularStyle400(
                    fontSize: 14, fontColor: asteriskColor ?? AppColors.grey1000),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _buildField(),
        // Inline error message
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildField() {
    final field = _buildTextFormField();
    if (trailing == null) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: 12),
        trailing!,
      ],
    );
  }

  Widget _buildTextFormField() {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? label,
        hintStyle: AppTextStyles.regularStyle400(
            fontSize: 16, fontColor: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.neutral300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.neutral300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
