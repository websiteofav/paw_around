import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/pets/widgets/circular_photo_picker.dart';
import 'package:paw_around/ui/pets/widgets/pet_form_selectors.dart';
import 'package:paw_around/ui/pets/widgets/pet_personality_selector.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class PetDetailsFormBody extends StatelessWidget {
  final TextEditingController breedController;
  final TextEditingController colourController;
  final TextEditingController aboutController;
  final double weightValue;
  final double heightValue;
  final String? selectedGender;
  final String? imagePath;
  final bool isImageLoading;
  final bool isSaving;
  final List<String> selectedPersonality;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<List<String>> onPersonalityChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;
  final VoidCallback onImageTap;
  final VoidCallback? onSave;
  final VoidCallback? onSkip;

  const PetDetailsFormBody({
    super.key,
    required this.breedController,
    required this.colourController,
    required this.aboutController,
    required this.weightValue,
    required this.heightValue,
    required this.selectedGender,
    required this.imagePath,
    required this.isImageLoading,
    required this.isSaving,
    required this.selectedPersonality,
    required this.onGenderChanged,
    required this.onPersonalityChanged,
    required this.onWeightChanged,
    required this.onHeightChanged,
    required this.onImageTap,
    required this.onSave,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const PetStepIndicator(current: 1, total: 2),
        const SizedBox(height: 40),
        Center(
          child: CircularPhotoPicker(
              imagePath: imagePath,
              isLoading: isImageLoading,
              onTap: onImageTap),
        ),
        const SizedBox(height: 36),
        CommonFormField(
          label: AppStrings.breed,
          hintText: AppStrings.hintBreed,
          controller: breedController,
          isRequired: false,
        ),
        const SizedBox(height: 36),
        const _FieldLabel(AppStrings.genderOptional),
        const SizedBox(height: 8),
        PetGenderSelector(selected: selectedGender, onChanged: onGenderChanged),
        const SizedBox(height: 36),
        const _FieldLabel(AppStrings.weight),
        const SizedBox(height: 12),
        PetRulerField(
            value: weightValue,
            min: 0,
            max: 150,
            step: 0.5,
            decimals: 1,
            onChanged: onWeightChanged),
        const SizedBox(height: 36),
        const _FieldLabel(AppStrings.height),
        const SizedBox(height: 12),
        PetRulerField(
            value: heightValue,
            min: 0,
            max: 300,
            step: 1,
            decimals: 0,
            onChanged: onHeightChanged),
        const SizedBox(height: 36),
        const _FieldLabel(AppStrings.colour),
        const SizedBox(height: 8),
        _PetTextField(
            controller: colourController, hint: AppStrings.colourHint),
        const SizedBox(height: 20),
        const _FieldLabel(AppStrings.aboutYourPet),
        const SizedBox(height: 8),
        _PetTextField(
            controller: aboutController,
            hint: AppStrings.aboutYourPetHint,
            maxLines: 4),
        const SizedBox(height: 36),
        const _FieldLabel(AppStrings.personality),
        const SizedBox(height: 8),
        PetPersonalitySelector(
            options: kPetPersonalityOptions,
            selected: selectedPersonality,
            onChanged: onPersonalityChanged),
        const SizedBox(height: 32),
        CommonButton(
          text: AppStrings.saveDetails,
          onPressed: onSave,
          isLoading: isSaving,
          textStyle: AppTextStyles.interBoldStyle700(
            fontSize: 16,
            fontColor: AppColors.grey1000,
          ),
        ),
        const SizedBox(height: 12),
        CommonButton(
          text: AppStrings.skipForNow,
          onPressed: onSkip,
          variant: ButtonVariant.outline,
          textStyle: AppTextStyles.interBoldStyle700(
              fontSize: 16, fontColor: AppColors.secondaryCTA),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.interRegularStyle400(
            fontSize: 14, fontColor: AppColors.grey1000));
  }
}

class _PetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _PetTextField(
      {required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.regularStyle400(
          fontSize: 16, fontColor: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.regularStyle400(fontColor: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neutral300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neutral300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.neutral300, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
