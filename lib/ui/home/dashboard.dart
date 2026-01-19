import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/home/widgets/dashboard_bottom_bar.dart';

class Dashboard extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const Dashboard({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime? _lastBackPressTime;

  Future<bool> _handleBackPress() async {
    final router = GoRouter.of(context);
    final isHomeRoute = widget.currentLocation == AppRoutes.home;

    // If we can pop, let GoRouter handle it normally
    if (router.canPop()) {
      return false; // Don't handle - let GoRouter pop normally
    }

    // If we can't pop and we're not at home (deep link opened directly),
    // navigate to home instead of exiting
    if (!isHomeRoute) {
      router.go(AppRoutes.home);
      return true; // Handled - navigated to home
    }

    // We're at home and can't pop - show exit confirmation
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
    // Use location passed from ShellRoute builder (stable API)
    final isHomeRoute = widget.currentLocation == AppRoutes.home;

    return BackButtonListener(
      onBackButtonPressed: _handleBackPress,
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBody: true, // Allow body to extend behind floating action button
        body:
            widget.child, // Content extends fully behind transparent bottom bar
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // Hide bottom nav when showing detail routes
        floatingActionButton: isHomeRoute ? const DashboardBottomBar() : null,
      ),
    );
  }
}
