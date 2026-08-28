import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/services/deep_link_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/ui/home/home_screen.dart';
import 'package:paw_around/ui/home/map_screen.dart';
import 'package:paw_around/ui/home/paw_circle_screen.dart';
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

    // Set up deep link handling after dashboard is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Enable immediate deep link processing and provide context
      DeepLinkService.instance.setAuthenticated(true, context);
      // Process any pending deep link
      DeepLinkService.instance.handlePendingUri();
    });
  }

  Future<bool> _handleBackPress() async {
    if (GoRouter.of(context).canPop()) {
      return false; // Don't handle - let GoRouter pop normally
    }
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.pressBackAgainToExit),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return true; // Handled - don't pop
    }
    SystemNavigator.pop();
    return true; // Handled
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: _handleBackPress,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final currentIndex =
              state is HomeTabSelected ? state.currentTabIndex : 0;
          final mapFilter =
              state is HomeTabSelected ? state.mapServiceFilter : null;

          final pawCircleInitialTab =
              state is HomeTabSelected ? state.pawCircleInitialTab : null;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: _getTabContent(currentIndex,
                mapFilter: mapFilter, pawCircleInitialTab: pawCircleInitialTab),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: smoothDecoration(
                cornerRadius: 24,
                color: AppColors.grey1000,
                side: const BorderSide(width: 0.6, color: AppColors.grey600),
                shadows: [
                  BoxShadow(
                    color: AppColors.navBarShadow.withValues(alpha: 0.98),
                    offset: const Offset(0, 3),
                    blurRadius: 7,
                  ),
                  BoxShadow(
                    color: AppColors.navBarShadow.withValues(alpha: 0.85),
                    offset: const Offset(0, 12),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: AppColors.navBarShadow.withValues(alpha: 0.50),
                    offset: const Offset(0, 27),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: AppColors.navBarShadow.withValues(alpha: 0.15),
                    offset: const Offset(0, 48),
                    blurRadius: 19,
                  ),
                  BoxShadow(
                    color: AppColors.navBarShadow.withValues(alpha: 0.02),
                    offset: const Offset(0, 76),
                    blurRadius: 21,
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        context: context,
                        icon: AppIcons.dashboardHomeIcon,
                        label: AppStrings.homeTab,
                        index: 0,
                        isSelected: currentIndex == 0,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: AppIcons.dashboardExploreIcon,
                        label: AppStrings.explore,
                        index: 1,
                        isSelected: currentIndex == 1,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: AppIcons.dashboardPawCircleIcon,
                        label: AppStrings.pawCircle,
                        index: 2,
                        isSelected: currentIndex == 2,
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

  Widget _getTabContent(int currentIndex,
      {ServiceType? mapFilter, int? pawCircleInitialTab}) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return MapScreen(initialFilter: mapFilter);
      case 2:
        return PawCircleScreen(initialTab: pawCircleInitialTab);
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String icon,
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
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.navigationInactive,
                  BlendMode.srcIn),
              height: 24,
              width: 24,
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
