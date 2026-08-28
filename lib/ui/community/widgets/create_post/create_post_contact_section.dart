import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';
import 'package:paw_around/utils/validators.dart';

/// "How can the owner reach you?" phone field + info banner.
class CreatePostContactSection extends StatelessWidget {
  final TextEditingController controller;

  const CreatePostContactSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.howCanTheOwnerReachYou,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 13, fontColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        CommonTextField(
          controller: controller,
          hintText: AppStrings.enterContactPhone,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
        ),
        const SizedBox(height: 12),
        const InfoBanner(text: AppStrings.contactOnlySharedWithRelevantUsers),
      ],
    );
  }
}
