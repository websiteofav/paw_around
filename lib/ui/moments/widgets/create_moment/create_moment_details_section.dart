import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/utils/validators.dart';

/// Title (required) + caption (optional) fields for the moment.
class CreateMomentDetailsSection extends StatelessWidget {
  final String? petName;
  final TextEditingController titleController;
  final TextEditingController captionController;

  const CreateMomentDetailsSection({
    super.key,
    required this.petName,
    required this.titleController,
    required this.captionController,
  });

  @override
  Widget build(BuildContext context) {
    final hasPetName = petName != null && petName!.isNotEmpty;
    final titleHint = hasPetName
        ? AppStrings.whatsPetUpTo(petName!)
        : AppStrings.momentTitleHint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.momentTitleLabel,
          style: AppTextStyles.interRegularStyle400(
              fontSize: 14, fontColor: AppColors.grey1000),
        ),
        const SizedBox(height: 12),
        CommonTextField(
          controller: titleController,
          hintText: titleHint,
          validator: (value) =>
              Validators.required(value, AppStrings.momentTitleLabel),
          fillColor: AppColors.white,
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.addCaption,
          style: AppTextStyles.interRegularStyle400(
              fontSize: 14, fontColor: AppColors.grey1000),
        ),
        const SizedBox(height: 12),
        CommonTextField(
          controller: captionController,
          hintText: AppStrings.momentCaptionHint,
          maxLines: 4,
          fillColor: AppColors.white,
        ),
      ],
    );
  }
}
