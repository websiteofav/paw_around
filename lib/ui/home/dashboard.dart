import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/ui/home/home_screen.dart';
import 'package:paw_around/ui/home/map_screen.dart';
import 'package:paw_around/ui/home/community_screen.dart';
import 'package:paw_around/ui/home/profile_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    // Load pets when dashboard is shown
    context.read<PetsBloc>().add(const LoadPets());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final currentIndex = state is HomeTabSelected ? state.currentTabIndex : 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: _getTabContent(currentIndex),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.navigationBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navigationBorder,
                  offset: Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: AppStrings.homeTab,
                      index: 0,
                      isSelected: currentIndex == 0,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.location_on_outlined,
                      activeIcon: Icons.location_on,
                      label: AppStrings.mapTab,
                      index: 1,
                      isSelected: currentIndex == 1,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: AppStrings.communityTab,
                      index: 2,
                      isSelected: currentIndex == 2,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: AppStrings.profileTab,
                      index: 3,
                      isSelected: currentIndex == 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getTabContent(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const MapScreen();
      case 2:
        return const CommunityScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Update BLoC state
        context.read<HomeBloc>().add(HomeTabChanged(index));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : AppColors.navigationIcon,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.navigationText,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
