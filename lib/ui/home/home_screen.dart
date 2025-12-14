import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/home/widgets/appointment_cards.dart';
import 'package:paw_around/ui/home/widgets/pet_profile_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          AppStrings.homeTab,
          style: TextStyle(
            color: AppColors.navigationText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navigationBackground,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<PetListBloc, PetListState>(
        builder: (context, state) {
          List<PetModel> pets = [];
          if (state is PetListLoaded) {
            pets = state.pets;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // My Pets Section Title
                const Text(
                  'My Pets',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Pet Profile Cards (Horizontal scrollable)
                PetProfileCards(pets: pets),
                const SizedBox(height: 16),

                // Upcoming Vaccines & Appointments Card
                AppointmentCards(pets: pets),
                const SizedBox(height: 16),

                // Lost & Found Nearby Card
                _buildLostAndFoundCard(),
                const SizedBox(height: 16),

                // Featured Services Section
                _buildFeaturedServicesSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLostAndFoundCard() {
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(HomeTabChanged(2));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF59D), // Light yellow
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.lostAndFoundNearby,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPetImage('assets/pet1.png', 'Dachshund'),
                  const SizedBox(width: 12),
                  _buildPetImage('assets/pet2.png', 'Pomeranian'),
                  const SizedBox(width: 12),
                  _buildPetImage('assets/pet3.png', 'Corgi'),
                  const SizedBox(width: 12),
                  _buildPetImage('assets/pet4.png', 'Mixed Breed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(String imagePath, String breed) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.pets,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }

  Widget _buildFeaturedServicesSection() {
    return GestureDetector(
        onTap: () {
          context.read<HomeBloc>().add(HomeTabChanged(1));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.featuredServices,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildServiceCard('Paws & Claws', '4.8', 'assets/service1.png'),
                  const SizedBox(width: 12),
                  _buildServiceCard('Pet Care Plus', '4.6', 'assets/service2.png'),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildServiceCard(String name, String rating, String imagePath) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(5, (index) {
                      if (index < 4) {
                        return const Icon(
                          Icons.star,
                          color: Color(0xFFFFD700),
                          size: 12,
                        );
                      } else {
                        return const Icon(
                          Icons.star_half,
                          color: Color(0xFFFFD700),
                          size: 12,
                        );
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
