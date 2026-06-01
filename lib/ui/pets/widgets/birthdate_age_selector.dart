import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class BirthdateAgeSelector extends StatelessWidget {
  const BirthdateAgeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetFormBloc, PetFormState>(
      builder: (context, state) {
        final hasDate = state.dateOfBirth != null;
        final label =
            hasDate ? _formatDate(state.dateOfBirth!) : AppStrings.selectDate;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                _selectDateOfBirth(context, state);
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: smoothDecoration(
                  cornerRadius: 12,
                  color: AppColors.white,
                  side: const BorderSide(color: AppColors.neutral300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.regularStyle400(
                          fontSize: 16,
                          fontColor: hasDate
                              ? AppColors.neutral900
                              : AppColors.neutral300,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_month,
                        size: 22, color: AppColors.secondaryCTA),
                  ],
                ),
              ),
            ),
            if (state.errors['dateOfBirth'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  state.errors['dateOfBirth']!,
                  style: AppTextStyles.regularStyle400(
                      fontSize: 12, fontColor: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDateOfBirth(
      BuildContext context, PetFormState state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null && context.mounted) {
      context.read<PetFormBloc>().add(SelectDateOfBirth(date, isExact: true));
    }
  }
}
