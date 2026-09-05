import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/addresses/address/address_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_event.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/services/deep_link_service.dart';
import 'package:paw_around/ui/home/home_screen.dart';
import 'package:paw_around/ui/home/map_screen.dart';
import 'package:paw_around/ui/home/paw_circle_screen.dart';
import 'package:paw_around/ui/home/widgets/dashboard_bottom_nav.dart';
import 'package:paw_around/ui/sitter/sitter_coming_soon_screen.dart';
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
    // Prefetch saved addresses too — used by the "Add new Address" flow
    // (see LocationDetailsScreen) regardless of the Sitter tab's state.
    context.read<AddressBloc>().add(const LoadAddresses());

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
            floatingActionButton: DashboardBottomNav(
              currentIndex: currentIndex,
              onTabSelected: (index) =>
                  context.read<HomeBloc>().add(HomeTabChanged(index)),
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
        // Book Sitters (SitterScreen/BookSittersScreen/UpcomingSessionScreen)
        // is fully built but gated behind a "Coming Soon" placeholder for
        // this release — see SitterComingSoonScreen's doc comment.
        return const SitterComingSoonScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
