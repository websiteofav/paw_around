import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final currentIndex =
            state is HomeTabSelected ? state.currentTabIndex : 0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white, // Semi-transparent white
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 80,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                      label: AppStrings.explore,
                      index: 1,
                      isSelected: currentIndex == 1,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: AppStrings.pawCircle,
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

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Update BLoC state
          context.read<HomeBloc>().add(HomeTabChanged(index));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.navigationActive
                  : AppColors.navigationInactive,
              size: 24,
              weight: 12,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: isSelected
                  ? AppTextStyles.semiBoldStyle600(
                      fontSize: 12, fontColor: AppColors.primary)
                  : AppTextStyles.mediumStyle500(
                      fontSize: 12, fontColor: AppColors.navigationInactive),
            ),
          ],
        ),
      ),
    );
  }
}
