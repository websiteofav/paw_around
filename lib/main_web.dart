import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/web/landing_page.dart';

void main() {
  runApp(const WebLandingApp());
}

class WebLandingApp extends StatelessWidget {
  const WebLandingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          onPrimary: AppColors.white,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: baseTextTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navigationBackground,
          foregroundColor: AppColors.navigationText,
          elevation: AppConstants.elevationLow,
        ),
      ),
      home: const LandingPage(),
    );
  }
}
