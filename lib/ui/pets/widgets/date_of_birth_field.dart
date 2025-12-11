import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class DateOfBirthField extends StatelessWidget {
  const DateOfBirthField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        if (state is PetFormState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.dateOfBirth,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDateOfBirth(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.dateOfBirth != null ? _formatDate(state.dateOfBirth!) : 'Select Date of Birth',
                          style: TextStyle(
                            color: state.dateOfBirth != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              if (state.errors['dateOfBirth'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.errors['dateOfBirth']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _selectDateOfBirth(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      context.read<PetsBloc>().add(SelectPetDateOfBirth(date: date));
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
