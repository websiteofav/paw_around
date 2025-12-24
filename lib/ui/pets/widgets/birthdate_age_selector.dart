import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class BirthdateAgeSelector extends StatelessWidget {
  const BirthdateAgeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetFormBloc, PetFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  AppStrings.birthdateOrAge,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // First row: Date picker + Less than 1 year + 1-3 years
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Date picker option - shows selected date when picked
                  _AgeOption(
                    label: _getDatePickerLabel(state),
                    icon: Icons.calendar_today_outlined,
                    isSelected: _isExactDateSelected(state),
                    onTap: () => _selectDateOfBirth(context, state),
                  ),
                  const SizedBox(width: 8),
                  // Less than 1 year
                  _AgeOption(
                    label: AppStrings.lessThan1Year,
                    isSelected: _isAgeRangeSelected(state, 0, 1),
                    onTap: () => _selectAgeRange(context, 0, 1),
                  ),
                  const SizedBox(width: 8),
                  // 1-3 years
                  _AgeOption(
                    label: AppStrings.oneToThreeYears,
                    isSelected: _isAgeRangeSelected(state, 1, 3),
                    onTap: () => _selectAgeRange(context, 1, 3),
                  ),
                  const SizedBox(width: 8),
                  // 3-7 years
                  _AgeOption(
                    label: AppStrings.threeToSevenYears,
                    isSelected: _isAgeRangeSelected(state, 3, 7),
                    onTap: () => _selectAgeRange(context, 3, 7),
                  ),
                  const SizedBox(width: 8),
                  // 7+ years
                  _AgeOption(
                    label: AppStrings.moreThan7Years,
                    isSelected: _isAgeRangeSelected(state, 7, 100),
                    onTap: () => _selectAgeRange(context, 7, 15),
                  ),
                ],
              ),
            ),

            // Error message
            if (state.errors['dateOfBirth'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errors['dateOfBirth']!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _isAgeRangeSelected(PetFormState state, int minYears, int maxYears) {
    if (state.dateOfBirth == null || state.isExactDateOfBirth) {
      return false;
    }
    final now = DateTime.now();
    final ageInYears = (now.difference(state.dateOfBirth!).inDays / 365).floor();
    return ageInYears >= minYears && ageInYears < maxYears;
  }

  /// Date picker is selected when user explicitly picked an exact date
  bool _isExactDateSelected(PetFormState state) {
    return state.dateOfBirth != null && state.isExactDateOfBirth;
  }

  /// Returns the label for date picker - shows formatted date if selected
  String _getDatePickerLabel(PetFormState state) {
    if (state.dateOfBirth != null && state.isExactDateOfBirth) {
      final date = state.dateOfBirth!;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
    return AppStrings.selectDate;
  }

  void _selectAgeRange(BuildContext context, int minYears, int maxYears) {
    final now = DateTime.now();
    DateTime birthDate;

    if (minYears == 0 && maxYears == 1) {
      // Less than 1 year: set to 6 months ago
      birthDate = DateTime(now.year, now.month - 6, now.day);
    } else {
      // Other ranges: use middle of range
      final avgYears = (minYears + maxYears) ~/ 2;
      birthDate = DateTime(now.year - avgYears, now.month, now.day);
    }

    context.read<PetFormBloc>().add(SelectDateOfBirth(birthDate));
  }

  void _selectDateOfBirth(BuildContext context, PetFormState state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      context.read<PetFormBloc>().add(SelectDateOfBirth(date, isExact: true));
    }
  }
}

class _AgeOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeOption({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
