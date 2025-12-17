import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/utils/date_utils.dart';

class PetProfileCards extends StatelessWidget {
  final List<PetModel> pets;
  final bool isFromProfile;
  const PetProfileCards({super.key, required this.pets, this.isFromProfile = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: pets.length, // +1 for the "Add Pet" card
              itemBuilder: (context, index) {
                // Pet cards
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildPetCard(context, pets[index]),
                );
              },
            ),
          ),
          if (!isFromProfile) Expanded(flex: 1, child: _buildAddPetCard(context)),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet) {
    return GestureDetector(
      onTap: () {
        // Navigate to Add Pet screen with pre-filled data for editing
        context.pushNamed(AppRoutes.addPet, extra: pet);
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD), // Light blue
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63), // Brown color for dog
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipOval(
                child: pet.imagePath != null
                    ? Image.file(
                        File(pet.imagePath!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppIcons.pawIcon,
                            width: 25,
                            height: 25,
                          );
                        },
                      )
                    : Image.asset(
                        AppIcons.pawIcon,
                        width: 25,
                        height: 25,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Pet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.species}, ${AppDateUtils.calculateAge(pet.dateOfBirth)} years',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Add Pet screen
        context.pushNamed(AppRoutes.addPet);
      },
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(height: 8),
            Text(
              'Add Pet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
