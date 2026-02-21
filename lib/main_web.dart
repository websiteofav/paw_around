import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/firebase_options.dart';
import 'package:paw_around/web/landing_page.dart';
import 'package:paw_around/web/public_pet_page.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WebLandingApp());
}

class WebLandingApp extends StatelessWidget {
  const WebLandingApp({super.key});

  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: AppRoutes.publicPetProfile,
        name: AppRoutes.publicPetProfile,
        builder: (context, state) {
          final petId = state.pathParameters['petId'] ?? '';
          return PublicPetPage(petPublicId: petId);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}
