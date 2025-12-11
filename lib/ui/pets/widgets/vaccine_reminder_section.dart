import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class VaccineReminderSection extends StatelessWidget {
  const VaccineReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        if (state is VaccineFormState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.setReminder,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: state.setReminder,
                onChanged: (value) => context.read<PetsBloc>().add(
                      ToggleVaccineReminder(enabled: value),
                    ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
