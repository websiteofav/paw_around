import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_colors.dart';

class VaccineDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const VaccineDateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        if (state is VaccineFormState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onTap,
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
                          selectedDate != null ? _formatDate(selectedDate!) : 'Select $label',
                          style: TextStyle(
                            color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              if (state.errors[label.toLowerCase().replaceAll(' ', '')] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.errors[label.toLowerCase().replaceAll(' ', '')]!,
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

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
