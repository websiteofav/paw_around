import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/preferences_constants.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1200), () async {
      final authRepo = sl<AuthRepository>();
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool(PreferencesConstants.hasCompletedOnboarding) ?? false;
      final isLoggedIn = authRepo.isLoggedIn;
      if (mounted) {
        // if (!hasCompletedOnboarding) {
        //   context.goNamed(AppRoutes.onboarding);
        // } else
        if (!isLoggedIn) {
          context.goNamed(AppRoutes.phoneLogin);
        } else {
          context.goNamed(AppRoutes.home);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
          opacity: _fade,
          child: Image.asset(
            AppIcons.splashIcon,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          )),
    );
  }
}
