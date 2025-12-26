import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/ui/home/home_screen.dart';
import 'package:paw_around/ui/home/map_screen.dart';
import 'package:paw_around/ui/home/community_screen.dart';
import 'package:paw_around/ui/profile/profile_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    // Load pets when dashboard is shown
    context.read<PetListBloc>().add(const LoadPetList());
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.pressBackAgainToExit),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final currentIndex = state is HomeTabSelected ? state.currentTabIndex : 0;
          final mapFilter = state is HomeTabSelected ? state.mapServiceFilter : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: _getTabContent(currentIndex, mapFilter: mapFilter),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.navigationBackground,
                border: const Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
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
      ),
    );
  }

  Widget _getTabContent(int currentIndex, {ServiceType? mapFilter}) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return MapScreen(initialFilter: mapFilter);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.navigationActive : AppColors.navigationInactive,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.navigationActive : AppColors.navigationInactive,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
