import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/utils/validators.dart';

/// Breed / colour fields + a description textarea, with a heading that
/// reflects whether a specific pet ("About Max") or none ("About the Pet")
/// is selected.
class CreatePostAboutSection extends StatelessWidget {
  final String? petName;
  final TextEditingController breedController;
  final TextEditingController colorController;
  final TextEditingController descriptionController;

  const CreatePostAboutSection({
    super.key,
    required this.petName,
    required this.breedController,
    required this.colorController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final hasPetName = petName != null && petName!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasPetName ? '${AppStrings.about} $petName' : AppStrings.aboutThePet,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 13, fontColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: breedController,
                hintText: AppStrings.breed,
                validator: (value) =>
                    Validators.required(value, AppStrings.breed),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonTextField(
                controller: colorController,
                hintText: AppStrings.color,
                validator: (value) =>
                    Validators.required(value, AppStrings.color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CommonTextField(
          controller: descriptionController,
          hintText: hasPetName
              ? AppStrings.describeThePet
              : AppStrings.anythingNoticeable,
          maxLines: 3,
          validator: (value) =>
              Validators.required(value, AppStrings.petDescription),
        ),
      ],
    );
  }
}
