import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/upcoming_vaccine_model.dart';

class AppointmentCards extends StatelessWidget {
  final List<PetModel> pets;
  const AppointmentCards({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    final upcomingVaccines = context.read<PetListBloc>().getUpcomingVaccines(pets);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  AppStrings.upcomingVaccinesAndAppointments,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Display upcoming vaccines or empty state
          if (upcomingVaccines.isEmpty)
            const Text(
              'No upcoming vaccines',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            )
          else
            ...upcomingVaccines.take(2).map((upcoming) => _buildVaccineItem(upcoming)),

          if (upcomingVaccines.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'And ${upcomingVaccines.length - 2} more...',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // View Details button
          Center(
            child: GestureDetector(
              onTap: () {
                // Navigate to vaccine details or pet list
                // For now, you can navigate to a vaccine list screen
                // or we can create one. For simplicity, navigate to home/my-pets
                if (upcomingVaccines.isNotEmpty) {
                  context.pushNamed(AppRoutes.addPet);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  AppStrings.viewDetails,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineItem(UpcomingVaccineModel upcoming) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final date = upcoming.vaccine.nextDueDate;
    final formattedDate = '${monthNames[date.month - 1]} ${date.day}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$formattedDate: ${upcoming.vaccine.vaccineName} - ${upcoming.petName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
